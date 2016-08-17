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
          "Finished to execute '#{@definition.name}'"
        end

        def long_elapsed_time_text
          "The running time is longer than expected '#{@definition.name}'."
        end

        def additional_text
          "Failed to execute '#{@definition.name}' #{@definition.hipchat_additional_text}"
        end

        def job_instance_path
          Rails.application.routes.url_helpers.job_definition_job_instance_url(@definition, @instance, host: 'kuroko2.ckpd.co', protocol: 'https')
        end
      end
    end
  end
end
