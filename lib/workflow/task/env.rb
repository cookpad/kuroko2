module Workflow
  module Task
    class Env < Base

      def execute
        if option
          env = token.context['ENV'] || {}
          env.merge!(parse_option(option))

          token.context['ENV'] = env
        end

        :next
      end

      def validate
        parse_option(option)
      end

      private
      def parse_option(option)
        env = {}

        scanner = StringScanner.new(option)
        until scanner.eos?
          case
          when scanner.scan(/(\w+)="((?:\\"|.)*?)"/)
            env[scanner[1]] = scanner[2].gsub(/\\"/, '"')
          when scanner.scan(/(\w+)='((?:\\'|.)*?)'/)
            env[scanner[1]] = scanner[2].gsub(/\\'/, "'")
          when scanner.scan(/(\w+)=(\S+)/)
            env[scanner[1]] = scanner[2]
          when scanner.scan(/\s+/)
          else
            raise Workflow::AssertionError, "Syntax error option value of env: #{option}"
          end
        end

        env
      end
    end
  end
end
