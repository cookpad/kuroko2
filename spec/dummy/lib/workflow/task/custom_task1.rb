module Workflow
  module Task
    class CustomTask1 < Base

      def execute
        Kuroko2.logger.info("(token #{token.uuid}) Custom Task1")
        :next
      end
    end
  end
end
