module Workflow
  module Task
    class Queue < Base
      def execute
        if option.present?
          token.context['QUEUE'] = option
        else
          token.context['QUEUE'] = Execution::DEFAULT_QUEUE
        end

        :next
      end

      def validate
        unless /\A[\w_-]{1,180}\z/ === option
          raise Workflow::AssertionError, "Queue name must be match with /\A[\w_-]{1,255}\z/: #{option}"
        end

        unless Worker.where(queue: option, working: true).exists?
          raise Workflow::AssertionError, "No such queue : #{option}"
        end
      end
    end
  end
end
