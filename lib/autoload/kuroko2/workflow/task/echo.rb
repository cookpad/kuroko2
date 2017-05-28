module Kuroko2
  module Workflow
    module Task
      class Echo< Base
        def execute
          message = "(token #{token.uuid}) #{option}"

          token.job_instance.logs.info(message)
          Kuroko2.logger.info(message)

          :next
        end
      end
    end
  end
end
