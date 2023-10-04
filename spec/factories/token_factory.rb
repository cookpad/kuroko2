FactoryBot.define do
  factory :token, class: Kuroko2::Token do
    uuid { SecureRandom.uuid }
    path { '/' }
    script { 'execute:' }
    context { Hash.new }

    job_instance
    job_definition { job_instance.job_definition }
  end
end
