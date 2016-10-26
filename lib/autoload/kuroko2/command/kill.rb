module Kuroko2
  module Command
    class Kill
      def initialize(host, process = nil)
        @hostname = host
        @process  = process
      end

      def execute
        if (signal = ProcessSignal.poll(@hostname))
          Kuroko2.logger.info("[#{@hostname}-#{@process}] Send #{Signal.signame(signal.number)} signal to #{signal.pid}")
          Process.kill(signal.number, signal.pid)

          signal.destroy!
          signal
        end
      rescue SystemCallError => e
        signal.update_column(:message, "[#{@hostname}-#{@process}] #{e.class}: #{e.message}") rescue nil

        Kuroko2.logger.error("[#{@hostname}-#{@process}] #{e.class}: #{e.message}")
      end
    end
  end
end
