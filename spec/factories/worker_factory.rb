FactoryGirl.define do
  factory :worker, class: Kuroko2::Worker do
    hostname "localhost"
    sequence(:worker_id)
    queue "@default"
    working true
    suspendable true
  end
end
