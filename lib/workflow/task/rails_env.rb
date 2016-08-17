module Workflow
  module Task
    class RailsEnv < Base
      RAILS_ENVS = %w(development test staging production)

      def execute
        if option
          if !RAILS_ENVS.include?(option) || RAILS_ENVS.index(option) > RAILS_ENVS.index(Rails.env)
            raise(
              Workflow::AssertionError,
              "Argment error: option value of rails_env: #{option} is not settable."
            )
          end

          token.context['RAILS_ENV'] = option
        end

        :next
      end
    end
  end
end
