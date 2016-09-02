module Workflow
  module Task
    class TimeBase < Base
      class << self
        attr_reader :task_name

        def set_task_name(task_name)
          @task_name = task_name
        end
      end

      def execute
        if option.present?
          validate
          token.context[self.class.task_name] = to_minutes(option)
        end

        :next
      end

      def validate
        unless /\A\d+(?:h|m)?\z/ === option
          raise Workflow::AssertionError,
            "A value of #{self.class.task_name} should be a number."
        end
      end

      private

      def to_minutes(option)
        case option
        when /\A(\d+)h\z/
          $1.to_i * 60
        when /\A(\d+)m\z/
          $1.to_i
        else
          option.to_i
        end
      end
    end
  end
end
