FactoryBot.define do
  factory :job_definition, class: Kuroko2::JobDefinition do
    name { 'Job Definition' }
    description { 'This is description for the job definition.' }
    script { "noop:\n" }
    admins { build_list(:user, 1) }
    prevent_multi { false }
    memory_expectancy { create_memory_expectancy! }

    trait :with_revisions do
      transient do
        revisions_count { 1 }
      end

      after(:create) do |job_definition, evaluator|
        create_list(:script_revision, evaluator.revisions_count, job_definition: job_definition, script: "noop:\n")
      end
    end

    factory :job_definition_with_instances do
      transient do
        job_instances_count { 1 }
        job_instances_token_status { Kuroko2::Token::WORKING }
      end

      after(:create) do |job_definition, evaluator|
        create_list(:job_instance, evaluator.job_instances_count, job_definition: job_definition)
      end
    end
  end
end
