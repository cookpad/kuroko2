class Kuroko2::JobSuspendSchedule < Kuroko2::ApplicationRecord
  include Kuroko2::TableNameCustomizable

  belongs_to :job_definition

  validates :cron, format: { with: Kuroko2::JobSchedule::CRON_FORMAT }, uniqueness: { scope: :job_definition_id, case_sensitive: true }
  validate :validate_cron_schedule

  def suspend_times(time_from, time_to)
    it = Chrono::Iterator.new(cron, now: time_from - 1)
    suspend_times = []

    loop do
      next_time = it.next
      if next_time <= time_to
        suspend_times << next_time
      else
        break
      end
    end

    suspend_times.map(&:in_time_zone)
  end

  private

  def validate_cron_schedule
    if Kuroko2::JobSchedule::CRON_FORMAT === cron
      suspend_schedule = Chrono::Schedule.new(cron)
      if job_definition.job_schedules.empty?
        errors.add(:cron, "needs job schedules")
      else
        schedule = job_definition.job_schedules.each_with_object({}) do |launch_schedule_model, h|
          launch_schedule = Chrono::Schedule.new(launch_schedule_model.cron)
          Kuroko2::JobSchedule::CHRONO_SCHEDULE_METHODS.each do |method|
            h[method] ||= []

            suspend_schedule_list = suspend_schedule.public_send(method)
            # https://linux.die.net/man/5/crontab
            # > Note: The day of a command's execution can be specified by two fields
            # >  day of month, and day of week. If both fields are restricted (ie, aren't *),
            # >  the command will be run when either field matches the current time.
            # >  For example, "30 4 1,15 * 5" would cause a command to be run at 4:30 am
            # >  on the 1st and 15th of each month, plus every Friday.
            if launch_schedule.wdays? && launch_schedule.days?
              if (method == :wdays && suspend_schedule.wdays? && !suspend_schedule.days?) || (method == :days && !suspend_schedule.wdays? && suspend_schedule.days?)
                suspend_schedule_list = []
              end
            end

            h[method] |= launch_schedule.public_send(method) - suspend_schedule_list
          end
        end

        if schedule.values.all?(&:empty?)
          errors.add(:cron, "suspends all launched schedules")
        end
      end
    end
  rescue Chrono::Fields::Base::InvalidField => e
    errors.add(:cron, "has invalid field: #{e.message}")
  end
end
