FactoryGirl.define do
  factory :job_suspend_schedule do
    sequence(:cron) do |n|
      hour = n / 60 >= 1 ? (n / 60) : '*'
      "#{n % 60} #{hour} * * *"
    end
  end
end
