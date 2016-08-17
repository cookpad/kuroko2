class MemoryExpectancy < ActiveRecord::Base
  DEFAULT_VALUE = 0

  belongs_to :job_definition

  validates :expected_value, presence: true

  def memory_consumption_logs
    MemoryConsumptionLog.joins(:job_instance).merge(JobInstance.where(job_definition_id: job_definition_id))
  end

  # Calculates expected_value with latest consumption logs, then stores it,
  def calculate!
    if calculated_value = memory_consumption_logs.maximum(:value)
      update!(expected_value: calculated_value)
    end
  end
end
