module Kuroko2
  module Command
    module Executor
      DEFAULT_NUM_WORKERS = 4
      NUM_SYSTEM_WORKERS = 2   # master and monitor

      def self.num_workers
        @num_workers ||= (ENV['NUM_WORKERS'] || DEFAULT_NUM_WORKERS).to_i + NUM_SYSTEM_WORKERS
      end

      def initialize
        @stop = ServerEngine::BlockingFlag.new

        @hostname = ENV['HOSTNAME'] || Socket.gethostname
        @queue    = ENV['QUEUE'] || Execution::DEFAULT_QUEUE

        @command = if worker_id == 0
                     Command::Kill.new(@hostname, worker_id)
                   elsif worker_id == (Command::Executor.num_workers - 1)
                     Command::Monitor.new(hostname: @hostname, worker_id: worker_id)
                   else
                     @worker = Worker.where(hostname: @hostname, worker_id: worker_id, queue: @queue).first_or_initialize!
                     @worker.update_column(:suspendable, true)
                     Command::Shell.new(hostname: @hostname, worker_id: worker_id, worker: @worker, queue: @queue)
                   end
      end

      def run
        Kuroko2.logger = logger
        Kuroko2.logger.info "[#{@hostname}-#{worker_id}] Start worker"
        toggle_worker_status(true)
        $0 = "command-executor (worker_id=#{worker_id} command=#{@command.class.name})"

        sleep worker_id

        until @stop.wait(1 + rand)
          @command.execute
        end
      rescue Exception => e
        Kuroko2.logger.fatal("[#{@hostname}-#{worker_id}] #{e.class}: #{e.message}\n" +
          e.backtrace.map { |trace| "    #{trace}" }.join("\n"))

        raise e
      end

      def stop
        Kuroko2.logger.info "[#{@hostname}-#{worker_id}] Stop worker"
        toggle_worker_status(false)

        @stop.set!
      end

      private

      def toggle_worker_status(status)
        return false unless @command.kind_of?(Command::Shell)

        @worker.working = status
        @worker.save
      end

    end
  end
end
