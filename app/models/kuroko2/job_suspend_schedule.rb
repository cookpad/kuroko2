class Kuroko2::JobSuspendSchedule < Kuroko2::ApplicationRecord
  include Kuroko2::TableNameCustomizable

  belongs_to :job_definition

  validates :cron, format: { with: Kuroko2::JobSchedule::CRON_FORMAT }, uniqueness: { scope: :job_definition_id }
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

    suspend_times
  end

  private

  def validate_cron_schedule
    if Kuroko2::JobSchedule::CRON_FORMAT === cron
      Chrono::Iterator.new(self.cron).next
    end
    nil
  rescue Chrono::Fields::Base::InvalidField => e
    errors.add(:cron, "has invalid field: #{e.message}")
  end
end
