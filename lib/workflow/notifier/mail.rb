module Workflow
  module Notifier
    class Mail
      def initialize(job_instance)
        @job_instance = job_instance
        @definition   = job_instance.job_definition
      end

      def notify_working
        # do nothing
      end

      def notify_cancellation
        if @definition.notify_cancellation
          deliver_job_failure
        end
      end

      def notify_failure
        deliver_job_failure
      end

      def notify_critical
        deliver_job_failure
      end

      def notify_finished
        # do nothing
      end

      def notify_long_elapsed_time
        Notifications.notify_long_elapsed_time(@job_instance).deliver_now
      end

      private

      def deliver_job_failure
        Notifications.job_failure(@job_instance).deliver_now
      end
    end
  end
end
