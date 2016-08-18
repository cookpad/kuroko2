FactoryGirl.define do
  factory :token do
    uuid { SecureRandom.uuid }
    path '/'
    script 'execute:'
    context { Hash.new }

    job_definition { job_instance.job_definition if job_instance }
  end
end
