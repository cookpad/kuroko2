require 'kuroko2/workflow/shell_scanner'

module Kuroko2
  module Workflow
    class ScriptParser
      LINE_REGEXP = /\A(?<indent>\s+)?(?:(?<type>\w+):\s*(?<option>.+)?)?\z/

      def initialize(script)
        @script = script

        @root         = Node.new(:root)
        @node_stack   = [@root]
        @indent_stack = [-1]
      end

      def parse(validate: true)
        root = parse_lines(@script)
        root.validate_all if validate
        root
      end

      private

      def parse_lines(script)
        script.each_line.with_index do |line, no|
          next if line.start_with?('#') || /^\s*$/ === line

          if (matched = LINE_REGEXP.match(line.chomp))
            raise_syntax_error(no, 'syntax error.') if matched.captures.all?(&:nil?)

            indent = (matched[:indent] || '').length
            node   = Node.new(matched[:type], ShellScanner.new(matched[:option]).strip_comment.try!(:strip))

            case indent <=> @indent_stack.last
            when -1
              if (i = @indent_stack.index(indent))
                @node_stack = @node_stack[0, i]
                @indent_stack = @indent_stack[0, i]
              else
                raise_syntax_error(no, 'inconsistent indentation.')
              end
            when 0
              @node_stack.pop
              @indent_stack.pop
            when 1
              # do nothing
            end

            @node_stack.last.append_child(node)

            @node_stack << node
            @indent_stack << indent
          else
            raise raise_syntax_error(no, 'syntax error.')
          end
        end

        @root
      end

      def raise_syntax_error(no, message)
        raise Workflow::SyntaxError, "(line #{no + 1}) #{message}"
      end
    end
  end
end
