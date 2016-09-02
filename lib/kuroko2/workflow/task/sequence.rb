module Workflow
  module Task
    class Sequence < Base
      def execute
        Kuroko2.logger.info("(token #{token.uuid}) Sequence is executed with option '#{option}'")

        :next
      end
    end
  end
end
