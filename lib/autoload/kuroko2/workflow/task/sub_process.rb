module Kuroko2
  module Workflow
    module Task
      class SubProcess < Base
        def execute
          validate

          if (sub_process_id = token.context['sub_process_id'])
            instance = JobInstance.find(sub_process_id)

            if instance.working?
              :pass
            elsif instance.canceled_at?
              message = "(token #{token.uuid}) Sub process '##{instance.job_definition.id} #{instance.job_definition.name}' instance##{instance.job_definition.id}/#{instance.id} is canceled."
              token.job_instance.logs.warn(message)
              Kuroko2.logger.info(message)

              token.mark_as_failure

              :failure
            else
              token.context['sub_process_id'] = nil

              message = "(token #{token.uuid}) Sub process '##{instance.job_definition.id} #{instance.job_definition.name}' instance##{instance.job_definition.id}/#{instance.id} is finished."
              token.job_instance.logs.info(message)
              Kuroko2.logger.info(message)

              :next
            end
          else
            definition = JobDefinition.find(@node.option)
            launched_by = "'##{token.job_definition.id} #{token.job_definition.name}' instance##{token.job_definition.id}/#{token.job_instance.id}"
            instance = definition.create_instance(launched_by: launched_by)
            token.job_instance.logs.info("(token #{token.uuid}) Launched '##{instance.job_definition.id} #{instance.job_definition.name}' instance##{instance.job_definition.id}/#{instance.id} as a sub process.")

            token.context['sub_process_id'] = instance.id
            :pass
          end
        rescue ActiveRecord::RecordNotFound
          raise Workflow::AssertionError, "Job definition is not found for #{option}"
        end

        def validate
          unless /\A\d+\z/ === option
            raise Workflow::AssertionError, "Option of sub process should be a number."
          end
        end
      end
    end
  end
end
