module Kuroko2
  module Workflow
    module Task
      class Execute < Base
        DEFAULT_EXPECTED_TIME = 60 * 24 # 24 hours
        EXPECTED_TIME_NOTIFY_REMIND_TERM = 1.hours

        def execute
          if (execution = Execution.of(token).take)
            update_execution(execution)
          else
            validate

            token.context['CHDIR'] = chdir
            before_execute

            Execution.create!(token:          token,
              job_definition: token.job_definition,
              job_instance:   token.job_instance,
              shell:          shell,
              queue:          token.context['QUEUE'] || Execution::DEFAULT_QUEUE,
              context:        token.context)
            :pass
          end
        end

        def before_execute
        end

        def chdir
          nil
        end

        def shell
          option
        end

        def validate
          if option.blank?
            raise Workflow::AssertionError, "Option is required for execute"
          end
        end

        private

        def update_execution(execution)
          if execution.completed?
            Kuroko2.logger.info("(token #{token.uuid}) `#{execution.shell}` returns #{execution.exit_status}.")

            instance = token.job_instance
            message  = "(token #{token.uuid}) [#{execution.success? ? 'SUCCESS' : 'FAILURE'}] `#{execution.shell}` returns #{execution.exit_status}."
            if execution.output?
              message += <<-MESSAGE

```
#{execution.output.chomp}
```
            MESSAGE
            end

            if execution.success?
              instance.logs.info(message)
            else
              instance.logs.error(message)
            end

            execution.with_lock do
              execution.destroy
              execution.success? ? :next : :failure
            end
          else
            process_timeout_if_needed(execution)
            notify_long_elapsed_time_if_needed(execution)
            :pass
          end
        end

        def process_timeout_if_needed(execution)
          timeout = token.context['TIMEOUT'].to_i

          if timeout > 0 && ((execution.created_at + timeout.minutes) < Time.current) && execution.pid
            hostname = Worker.executing(execution.id).try(:hostname)
            if hostname
              ProcessSignal.create!(pid: execution.pid, hostname: hostname)
              message = "(token #{token.uuid}) Timeout occurred after #{timeout} minutes."
              token.job_instance.logs.info(message)
              Kuroko2.logger.info(message)
            else
              message = "(token #{token.uuid}) The timeout task is not working. Hostname not found on execution_id #{execution.id}"
              token.job_instance.logs.error(message)
              Kuroko2.logger.error(message)
            end
          end
        end

        def expected_time
          @expected_time ||= token.context['EXPECTED_TIME'].present? ?
            token.context['EXPECTED_TIME'].to_i :
            DEFAULT_EXPECTED_TIME
        end

        def available_notify_long_elapsed_time?(execution)
          if token.context['EXPECTED_TIME_NOTIFIED_AT'].present?
            token.context['EXPECTED_TIME_NOTIFIED_AT'] < EXPECTED_TIME_NOTIFY_REMIND_TERM.ago &&
              execution.pid.present?
          else
            execution.pid.present?
          end
        end

        def elapsed_expected_time?(execution)
          (execution.created_at + expected_time.minutes).past?
        end

        def notify_long_elapsed_time_if_needed(execution)
          if available_notify_long_elapsed_time?(execution) && elapsed_expected_time?(execution)
            token.context['EXPECTED_TIME_NOTIFIED_AT'] = Time.current
            Notifier.notify(:long_elapsed_time, token.job_instance)

            message = "(token #{token.uuid}) The running time is longer than #{expected_time} minutes!"
            token.job_instance.logs.info(message)
            Kuroko2.logger.info(message)
          end
        end
      end
    end
  end
end
