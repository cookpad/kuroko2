module Kuroko2
  module Servers
    class WorkflowProcessor < Base

      private

      def worker
        Kuroko2::Workflow::Processor
      end

      def default_options
        {
          worker_type: 'embedded',
          daemonize:   Rails.env.production?,
          log:         Rails.env.production? ?
            Rails.root.join("log/workflow-processor.log").to_s :
            $stdout,
          log_level:   Rails.env.production? ? :info : :debug,
          pid_path:    Rails.root.join('tmp/pids/workflow-processor.pid').to_s,
          supervisor:  Rails.env.production?,
        }
      end
    end
  end
end
