module Kuroko2
  module Workflow
    module Notifier
      module Concerns
        class ChatMessageBuilder
          def initialize(instance)
            @instance   = instance
            @definition = instance.job_definition
          end

          def failure_text
            "Failed to execute '#{@definition.name}'"
          end

          def finished_text
            "Finished executing '#{@definition.name}'"
          end

          def launched_text
            "Launched '#{@definition.name}'"
          end

          def back_to_normal_text
            "'#{@definition.name}' is back to normal"
          end

          def retrying_text
            "Retrying the current task in '#{@definition.name}'"
          end

          def skipping_text
            "Skipping the current task in '#{@definition.name}'"
          end

          def long_elapsed_time_text
            "The running time of '#{@definition.name}' is longer than expected."
          end

          def additional_text
            "Failed to execute '#{@definition.name}' #{@definition.hipchat_additional_text}"
          end

          def job_instance_path
            Kuroko2::Engine.routes.url_helpers.job_definition_job_instance_url(
              @definition,
              @instance,
              host: Kuroko2.config.url_host,
              protocol: Kuroko2.config.url_scheme,
            )
          end
        end
      end
    end
  end
end
