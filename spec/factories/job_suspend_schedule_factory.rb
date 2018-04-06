FactoryBot.define do
  factory :job_suspend_schedule, class: Kuroko2::JobSuspendSchedule do
    job_definition
  end
end
