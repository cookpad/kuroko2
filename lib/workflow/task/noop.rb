module Workflow
  module Task
    class Noop < Base
      def execute
        Kuroko2.logger.info("(token #{token.uuid}) NOOP")

        :next
      end
    end
  end
end
