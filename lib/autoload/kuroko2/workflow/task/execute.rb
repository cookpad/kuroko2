module Kuroko2
  module Workflow
    module Task
      class Execute < Base
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
            :pass
          end
        end

        def process_timeout_if_needed(execution)
          timeout = token.context['TIMEOUT'].to_i

          if timeout > 0 && ((execution.created_at + timeout.minutes) < Time.current) && execution.pid
            hostname = Worker.executing(execution.id).try!(:hostname)
            # XXX: Store pid and hostname for compatibility
            ProcessSignal.create!(pid: execution.pid, hostname: hostname, execution_id: execution.id)
            message = "(token #{token.uuid}) Timeout occurred after #{timeout} minutes."
            token.job_instance.logs.info(message)
            Kuroko2.logger.info(message)
          end
        end
      end
    end
  end
end
