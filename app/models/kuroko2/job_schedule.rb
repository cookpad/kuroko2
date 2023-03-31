class Kuroko2::JobSchedule < Kuroko2::ApplicationRecord
  include Kuroko2::TableNameCustomizable

  belongs_to :job_definition

  CRON_FORMAT = /\A
    (?:[1-5]?[0-9]|(?:[1-5]?[0-9]\-[1-5]?[0-9]|\*)(?:\/[1-5]?[0-9])?)(?:,(?:[1-5]?[0-9]|(?:[1-5]?[0-9]\-[1-5]?[0-9]|\*)(?:\/[1-5]?[0-9])?))*
    \s+
    (?:1?[0-9]|2[0-3]|(?:(?:1?[0-9]|2[0-3])\-(?:1?[0-9]|2[0-3])|\*)(?:\/(?:1?[0-9]|2[0-3]))?)(?:,(?:1?[0-9]|2[0-3]|(?:(?:1?[0-9]|2[0-3])\-(?:1?[0-9]|2[0-3])|\*)(?:\/(?:1?[0-9]|2[0-3]))?))*
    \s+
    (?:(?:[1-9]|[1-2][0-9]|3[0-1])|(?:(?:[1-9]|[1-2][0-9]|3[0-1])\-(?:[1-9]|[1-2][0-9]|3[0-1])|\*)(?:\/(?:[1-9]|[1-2][0-9]|3[0-1]))?)(?:,(?:(?:[1-9]|[1-2][0-9]|3[0-1])|(?:(?:[1-9]|[1-2][0-9]|3[0-1])\-(?:[1-9]|[1-2][0-9]|3[0-1])|\*)(?:\/(?:[1-9]|[1-2][0-9]|3[0-1]))?))*
    \s+
    (?:(?:[1-9]|1[0-2])|(?:(?:[1-9]|1[0-2])\-(?:[1-9]|1[0-2])|\*)(?:\/(?:[1-9]|1[0-2]))?)(?:,(?:(?:[1-9]|1[0-2])|(?:(?:[1-9]|1[0-2])\-(?:[1-9]|1[0-2])|\*)(?:\/(?:[1-9]|1[0-2]))?))*
    \s+
    (?:[0-6]|(?:(?:[0-6]\-[0-6]|\*)(?:\/[0-6])?))(?:,(?:[0-6]|(?:(?:[0-6]\-[0-6]|\*)(?:\/[0-6])?)))*
  \z/x

  CHRONO_SCHEDULE_METHODS = %i[minutes hours days months wdays]

  validates :cron, format: { with: CRON_FORMAT }, uniqueness: { scope: :job_definition_id, case_sensitive: true }
  validate :validate_cron_schedule

  def next(now = Time.current)
    return if suspended_all?

    next_time = Chrono::Iterator.new(self.cron, now: now).next
    suspend_times = suspend_times(next_time, next_time)

    if suspend_times.include?(next_time)
      self.next(next_time)
    else
      next_time
    end
  end

  def scheduled_times(time_from, time_to)
    it = Chrono::Iterator.new(cron, now: time_from)
    scheduled_times = []

    loop do
      next_time = it.next
      if next_time <= time_to
        scheduled_times << next_time
      else
        break
      end
    end

    scheduled_times.map(&:in_time_zone)
  end

  def suspend_times(time_from, time_to)
    if has_suspend_schedules?
      job_definition.job_suspend_schedules.
        map { |schedule| schedule.suspend_times(time_from, time_to) }.flatten.uniq
    else
      []
    end
  end

  private

  def suspended_all?
    return false unless has_suspend_schedules?

    launch_schedule = Chrono::Schedule.new(cron)
    schedule = CHRONO_SCHEDULE_METHODS.each_with_object({}) do |method, h|
      h[method] = launch_schedule.public_send(method)
    end

    job_definition.job_suspend_schedules.each do |suspend_schedule_model|
      suspend_schedule = Chrono::Schedule.new(suspend_schedule_model.cron)
      CHRONO_SCHEDULE_METHODS.each do |method|
        schedule[method] -= suspend_schedule.public_send(method)
      end

      # https://linux.die.net/man/5/crontab
      # > Note: The day of a command's execution can be specified by two fields
      # >  day of month, and day of week. If both fields are restricted (ie, aren't *),
      # >  the command will be run when either field matches the current time.
      # >  For example, "30 4 1,15 * 5" would cause a command to be run at 4:30 am
      # >  on the 1st and 15th of each month, plus every Friday.
      if suspend_schedule.wdays? && suspend_schedule.days?
        case
        when launch_schedule.wdays? && !launch_schedule.days?
          schedule[:days] = []
        when !launch_schedule.wdays? && launch_schedule.days?
          schedule[:wdays] = []
        end
      end
    end

    schedule.values.all?(&:empty?)
  end

  def has_suspend_schedules?
    job_definition && !job_definition.job_suspend_schedules.empty?
  end

  def validate_cron_schedule
    if CRON_FORMAT === cron
      self.next
    end
    nil
  rescue Chrono::Fields::Base::InvalidField => e
    errors.add(:cron, "has invalid field: #{e.message}")
  end

  def self.launch_scheduled_jobs!(time_from, time_to)
    includes(job_definition: :job_suspend_schedules).find_each do |schedule|
      definition = schedule.job_definition
      suspend_times = schedule.suspend_times(time_from, time_to)

      schedule.scheduled_times(time_from, time_to).each do |time|
        if definition.suspended?
          Kuroko2.logger.info("Skipped suspended \"##{definition.id} #{definition.name}\" that is scheduled at #{I18n.l(time, format: :short)} by `#{schedule.cron}`")
        elsif suspend_times.include?(time)
          Kuroko2.logger.info("Skipped schedule suspended \"##{definition.id} #{definition.name}\" that is scheduled at #{I18n.l(time, format: :short)} by `#{schedule.cron}`")
        else
          launched_by = "\"##{definition.id} #{definition.name}\" that is scheduled at #{I18n.l(time, format: :short)} by `#{schedule.cron}`"
          definition.create_instance(launched_by: launched_by)
        end
      end
    end
  end
end
