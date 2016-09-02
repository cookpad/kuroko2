module Workflow
  module Scheduler
    def initialize
      @hostname = Socket.gethostname

      @stop       = ServerEngine::BlockingFlag.new
      @processing = ServerEngine::BlockingFlag.new
    end

    def run
      Kuroko2.logger = logger
      Kuroko2.logger.info "[#{@hostname}-#{worker_id}] Start Workflow::Scheduler"

      until @stop.wait(2.0)
        unless @processing.set?
          begin
            @processing.set!
            JobSchedule.transaction do
              now = Time.now
              last_scheduled_time = Tick.fetch_then_update(now)
              JobSchedule.launch_scheduled_jobs!(last_scheduled_time, now)
            end
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
      Kuroko2.logger.info "[#{@hostname}-#{worker_id}] Stop Workflow::Scheduler"

      @stop.set!
    end
  end
end
