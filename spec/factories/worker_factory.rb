FactoryGirl.define do
  factory :worker do
    hostname "localhost"
    sequence(:worker_id)
    queue "@default"
    working true
  end
end
