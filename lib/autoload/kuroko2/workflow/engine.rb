module Kuroko2
  module Workflow
    class Engine
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

          Notifier.notify(:retring, token.job_instance)
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
          failure(token)
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
          token.mark_as_finished
          unless token.parent
            token.job_instance.touch(:finished_at)
            token.destroy!
          end

          Kuroko2.logger.info(message)

          Notifier.notify(:finished, token.job_instance)
        end
      end

      def process_with_lock(token)
        node = extract_node(token)

        execute_task(node, token)
      rescue EngineError => e
        message = "#{e.message}\n" + e.backtrace.map { |trace| "    #{trace}" }.join("\n")

        token.mark_as_critical(e)
        token.job_instance.logs.error("(token #{token.uuid}) #{message}")
        token.job_instance.touch(:canceled_at)

        Token.delete_all(job_definition: token.job_definition)
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
    end
  end
end
