module Kuroko2
  module Workflow
    module Task
      class Fork < Base
        def execute
          children = token.children
          if children.empty?
            message = "(token #{token.uuid}) Start to fork."

            token.job_instance.logs.info(message)
            Kuroko2.logger.info(message)

            node.children.each do |child|
              attributes = token.attributes.except('id', 'uuid', 'script', 'path', 'message', 'created_at', 'updated_at')
              attributes = attributes.merge(uuid: SecureRandom.uuid, parent: token, script: child.to_script, path: '/')

              Token.create(attributes).tap do |created|
                message = "(token #{created.uuid}) New token are created for #{node.path}"
                created.job_instance.logs.info(message)

                Kuroko2.logger.info(message)
              end
            end
            :pass
          elsif children.all?(&:finished?)
            message = "(token #{token.uuid}) All children are finished."

            token.job_instance.logs.info(message)
            Kuroko2.logger.info(message)

            :next_sibling
          else
            :pass
          end
        end

        def validate
          if node.children.empty?
            raise Workflow::AssertionError, "Fork must have children node"
          end
        end
      end
    end
  end
end
