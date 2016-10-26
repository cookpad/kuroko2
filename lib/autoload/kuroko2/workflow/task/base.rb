module Kuroko2
  module Workflow
    module Task
      class Base
        def initialize(node, token)
          @node  = node
          @token = token
        end

        def execute
          raise NotImplementedError
        end

        def validate
        end

        private
        def token
          @token
        end

        def node
          @node
        end

        def option
          @_option ||= @node.option
        end
      end
    end
  end
end
