module Kuroko2
  class ExecutionLogger::Void
    def initialize(**)
    end

    def send_log(message)
    end

    def get_logs(token = nil)
      raise ExecutionLogger::NotFound
    end
  end
end
