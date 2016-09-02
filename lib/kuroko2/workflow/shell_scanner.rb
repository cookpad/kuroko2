require 'strscan'

module Kuroko2
  module Workflow
    class ShellScanner
      STRING_LITERAL = /("([^"]|\")*"|'([^']|\')*')/

      def initialize(text)
        @text = text
      end

      def strip_comment
        return @text if @text.nil?

        result = ''
        while scanner.rest?
          break if scanner.peek(1) == '#'

          token = scanner.scan(/[^'"#]+/) || scanner.scan(STRING_LITERAL) || scanner.scan(/[^#]+/)
          break if token.nil?

          result << token
        end
        result
      end

      private

      def scanner
        @scanner ||= StringScanner.new(@text)
      end
    end
  end
end
