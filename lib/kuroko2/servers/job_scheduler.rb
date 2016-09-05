require 'kuroko2/servers/base'

module Kuroko2
  module Servers
    class JobScheduler < Base

      private

      def worker
        Kuroko2::Workflow::Scheduler
      end

      def default_options
        {
          worker_type: 'embedded',
          daemonize:   Rails.env.production?,
          log:         Rails.env.production? ? Rails.root.join('log/job-scheduler.log').to_s : $stdout,
          log_level:   Rails.env.production? ? :info : :debug,
          pid_path:    Rails.root.join('tmp/pids/job-scheduler.pid').to_s,
          supervisor:  Rails.env.production?,
        }
      end
    end
  end
end
