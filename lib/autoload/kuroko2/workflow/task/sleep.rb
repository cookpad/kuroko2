module Kuroko2
  module Workflow
    module Task
      class Sleep < Base
        def execute
          if (time = token.context['SLEEP'])
            if Time.current.to_i > time
              token.context.delete('SLEEP')

              :next
            else
              :pass
            end
          else
            token.context['SLEEP'] = Time.current.to_i + option.to_i

            :pass
          end
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
