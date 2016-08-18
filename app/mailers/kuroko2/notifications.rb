module Kuroko2
  class Notifications < ApplicationMailer
    default(
      from: Kuroko2.config.notifiers.mail.mail_from,
      to:   Kuroko2.config.notifiers.mail.mail_to,
    )
    helper_method :job_instance_url

    def job_failure(job_instance)
      @definition = job_instance.job_definition
      @instance   = job_instance

      attachments.inline['kuroko-logo-horizontal.jpg'] = Kuroko2::Engine.root.join('app/assets/images/kuroko2/kuroko-logo-horizontal.png').read

      mail(subject: "[CRITICAL] Failed to execute '#{@definition.name}' on kuroko",
        to:      @definition.admins.map(&:email),
        cc:      Kuroko2.config.notifiers.mail.mail_to)
    end

    def remind_failure(job_instance)
      @definition = job_instance.job_definition
      @instance   = job_instance

      attachments.inline['kuroko-logo-horizontal.jpg'] = Kuroko2::Engine.root.join('app/assets/images/kuroko-logo-horizontal.png').read

      mail(subject: "[WARN] '#{@definition.name}' is still in ERROR state",
        to:      @definition.admins.map(&:email),
        cc:      Kuroko2.config.notifiers.mail.mail_to)
    end

    def process_absence(execution, hostname)
      @execution  = execution
      @definition = execution.job_definition
      @instance   = execution.job_instance
      @hostname   = hostname

      mail(subject: '[CRITICAL] Process is not running on kuroko')
    end

    def executor_not_assigned(execution, hostname)
      @execution  = execution
      @definition = execution.job_definition
      @instance   = execution.job_instance

      mail(subject: '[CRITICAL] Process is not assigned to any job-executor')
    end

    def notify_long_elapsed_time(job_instance)
      @definition = job_instance.job_definition
      @instance   = job_instance

      mail(subject: "[WARN] The running time is longer than expected '#{@definition.name}' on kuroko",
        to:      @definition.admins.map(&:email),
        cc:      Kuroko2.config.notifiers.mail.mail_to)
    end

    private

    def job_instance_url
      job_definition_job_instance_url(@definition, @instance)
    end
  end
end
