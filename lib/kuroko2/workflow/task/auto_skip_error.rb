module Kuroko2
  module Workflow
    module Task
      class AutoSkipError < Base
        TRUE_OPTIONS = ['1', 'true', 'TRUE']

        def execute
          token.context['AUTO_SKIP_ERROR'] = auto_skip_error?
          Kuroko2.logger.info("(token #{token.uuid}) AUTO_SKIP_ERROR: #{auto_skip_error?}")
          :next
        end

        def auto_skip_error?
          return @auto_skip_error if defined? @auto_skip_error
          @auto_skip_error = option ? TRUE_OPTIONS.include?(option.strip) : false
        end
      end
    end
  end
end
