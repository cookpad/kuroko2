module Workflow
  module Processor
    def initialize
      @hostname = Socket.gethostname

      @stop       = ServerEngine::BlockingFlag.new
      @processing = ServerEngine::BlockingFlag.new

      @workflow = Workflow::Engine.new
    end

    def run
      Kuroko2.logger = logger
      Kuroko2.logger.info "[#{@hostname}-#{worker_id}] Start Workflow::Processor"

      until @stop.wait(1.0)
        unless @processing.set?
          begin
            @processing.set!
            @workflow.process_all
            @processing.reset!
          end
        end
      end
    rescue Exception => e
      Kuroko2.logger.fatal("[#{@hostname}-#{worker_id}] #{e.class}: #{e.message}\n" +
                            e.backtrace.map { |trace| "    #{trace}" }.join("\n"))

      raise e
    end

    def stop
      Kuroko2.logger.info "[#{@hostname}-#{worker_id}] Stop Workflow::Processor"

      @stop.set!
    end
  end
end
