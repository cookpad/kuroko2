module Kuroko2
  module Workflow
    class Engine
      DEFAULT_EXPECTED_TIME = 60 * 24 # 24 hours
      EXPECTED_TIME_NOTIFY_REMIND_TERM = 1.hours

      def process_all
        Token.processable.each do |token|
          process(token)
        end
      end

      def process(token)
        unless token.working? || token.waiting?
          Kuroko2.logger.info { "(token #{token.uuid}) Skip since current status marked as '#{token.status_name}'." }

          return
        end

        token.with_lock { process_with_lock(token) }
      end

      def retry(token)
        token.with_lock do
          node = extract_node(token)

          message = "(token #{token.uuid}) Retry current node: '#{node.type}: #{node.option}'"
          token.job_instance.update_column(:error_at, nil)
          token.job_instance.logs.info(message)

          token.mark_as_working
          token.save!

          Kuroko2.logger.info(message)

          Notifier.notify(:retrying, token.job_instance)
        end
      end

      def skip(token)
        token.with_lock do
          node = extract_node(token)

          message = "(token #{token.uuid}) Skip current node: '#{node.type}: #{node.option}'"
          token.job_instance.update_column(:error_at, nil)
          token.job_instance.logs.info(message)

          token.mark_as_working
          process_next(node.next, token)

          token.save! unless token.destroyed?

          Kuroko2.logger.info(message)

          Notifier.notify(:skipping, token.job_instance)
        end
      end

      def failure(token)
        message = "(token #{token.uuid}) Mark as failure."

        token.job_instance.logs.error(message)
        token.job_instance.touch(:error_at)
        token.mark_as_failure

        Kuroko2.logger.info(message)

        Notifier.notify(:failure, token.job_instance)

        if token.context['AUTO_SKIP_ERROR']
          skip(token)
        end
      end

      private

      def execute_task(node, token)
        result = node.execute(token)

        case result
        when :next
          process_next(node.next, token)
        when :next_sibling
          process_next(node.next_sibling, token)
        when :pass
          # Do nothing
        when :failure
          if auto_retryable?(node, token)
            auto_retry(node, token)
          else
            failure(token)
          end
        end
      rescue KeyError => e
        raise EngineError.new(e.message)
      end

      def process_next(node, token)
        if node
          message = "(token #{token.uuid}) Current node is '#{token.path}'."

          token.path = node.path
          token.job_instance.logs.info(message)

          Kuroko2.logger.info(message)
        else
          message = "(token #{token.uuid}) Marked as 'finished'."

          token.job_instance.logs.info(message)
          Kuroko2.logger.info(message)
          token.mark_as_finished
          unless token.parent
            token.job_instance.touch(:finished_at)
            Notifier.notify(:finished, token.job_instance)
            token.destroy!
          end
        end
      end

      def process_with_lock(token)
        node = extract_node(token)

        execute_task(node, token)
        notify_long_elapsed_time_if_needed(token)
      rescue EngineError => e
        message = "#{e.message}\n" + e.backtrace.map { |trace| "    #{trace}" }.join("\n")

        token.mark_as_critical(e)
        token.job_instance.logs.error("(token #{token.uuid}) #{message}")
        token.job_instance.touch(:canceled_at)

        Token.where(job_definition: token.job_definition).delete_all
        token.job_instance.logs.warn("(token #{token.uuid}) This job is canceled.")

        Kuroko2.logger.error(message)
        Notifier.notify(:critical, token.job_instance)
      ensure
        token.save! unless token.destroyed?
      end

      def extract_node(token)
        root = ScriptParser.new(token.script).parse(validate: false)
        root.find(token.path)
      end

      def expected_time(token)
        token.context['EXPECTED_TIME'].present? ?
          token.context['EXPECTED_TIME'].to_i :
          DEFAULT_EXPECTED_TIME
      end

      def available_notify_long_elapsed_time?(token)
        return false if token.parent && expected_time(token) == expected_time(token.parent)
        token.context['EXPECTED_TIME_NOTIFIED_AT'].nil? || Time.zone.parse(token.context['EXPECTED_TIME_NOTIFIED_AT']) < EXPECTED_TIME_NOTIFY_REMIND_TERM.ago
      end

      def elapsed_expected_time?(token)
        (token.created_at + expected_time(token).minutes).past?
      end

      def notify_long_elapsed_time_if_needed(token)
        if available_notify_long_elapsed_time?(token) && elapsed_expected_time?(token)
          token.context['EXPECTED_TIME_NOTIFIED_AT'] = Time.current
          Notifier.notify(:long_elapsed_time, token.job_instance)

          message = "(token #{token.uuid}) The running time is longer than #{expected_time(token)} minutes!"
          token.job_instance.logs.info(message)
          Kuroko2.logger.info(message)
        end
      end

      def auto_retry(node, token)
        token.context['RETRY'][node.path]['current'] += 1

        message = "(token #{token.uuid}) Retry current node: '#{node.type}: #{node.option}'"
        token.job_instance.logs.info(message)
        Kuroko2.logger.info(message)

        message = "(token #{token.uuid}) The number of retries: " << 
          "#{token.context['RETRY'][node.path]['current']} / #{token.context['RETRY'][node.path]['count']}"
        token.job_instance.logs.info(message)
        Kuroko2.logger.info(message)

        sleep_for_each_retry(node, token)
      end

      def sleep_for_each_retry(node, token)
        if token.context['RETRY'].present? && token.context['RETRY'][node.path].present?
          started_time = Time.current.to_i
          while started_time + token.context['RETRY'][node.path]['sleep_time'] > Time.current.to_i
            # sleep
          end
        end
      end

      def auto_retryable?(node, token)
        token.context['RETRY'].present? &&
          token.context['RETRY'][node.path].present? &&
          token.context['RETRY'][node.path]['count'] > token.context['RETRY'][node.path]['current']
      end
    end
  end
end