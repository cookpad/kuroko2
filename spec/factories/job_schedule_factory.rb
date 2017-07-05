FactoryGirl.define do
  factory :job_schedule, class: Kuroko2::JobSchedule do
    sequence(:cron) do |n|
      hour = n > 60 ? (n / 60) : '*'
      day  = n > 60 * 24 ? n / 60 % 24 : '*'

      "#{n % 60} #{hour} #{day} * *"
    end

    job_definition
  end
end
