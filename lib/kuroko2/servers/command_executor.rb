module Kuroko2
  module Servers
    class CommandExecutor < Base

      private

      def worker
        Kuroko2::Command::Executor
      end

      def default_options
        {
          worker_type: 'process',
          workers:     Kuroko2::Command::Executor.num_workers,
          daemonize:   Rails.env.production?,
          log:         Rails.env.production? ?
            Rails.root.join("log/command-executor.log").to_s :
            $stdout,
          log_level:   Rails.env.production? ? :info : :debug,
          pid_path:    Rails.root.join('tmp/pids/command-executor.pid').to_s,
          supervisor:  Rails.env.production?,
          worker_graceful_kill_timeout: -1,
        }
      end
    end
  end
end
