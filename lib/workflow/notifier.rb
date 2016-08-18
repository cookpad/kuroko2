module Workflow
  module Notifier
    NOTIFY_IN_THREAD = !Rails.env.test?

    def self.notify(method, job_instance)
      Kuroko2.config.notifiers.keys.each do |notifier_name|
        notifier = const_get(notifier_name.camelize, false)
        if NOTIFY_IN_THREAD
          Thread.new { notify_with_notifier(job_instance, method, notifier) }
        else
          # for test
          notify_with_notifier(job_instance, method, notifier)
        end
      end
    end

    def self.notify_with_notifier(job_instance, method, notifier)
      begin
        ActiveRecord::Base.connection_pool.with_connection do
          notifier.new(job_instance).send(:"notify_#{method}")
        end
      rescue Exception => e
        Kuroko2.logger.warn("Failure to notify #{method} with #{notifier} for '#{job_instance.job_definition.name}'. #{e.class}: #{e.message}")
      end
    end

    private_class_method :notify_with_notifier
  end
end
