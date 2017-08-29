module Kuroko2
  module Workflow
    module Task
      class Sleep < Base
        def execute
          token.context['SLEEP'] = Time.current.to_i + option.to_i

          :next
        end

        def validate
          unless /^\d+$/ === option
            raise Workflow::AssertionError, "A value of sleep should be a number."
          end
        end
      end
    end
  end
end
