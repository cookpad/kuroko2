FactoryGirl.define do
  factory :job_definition do
    name 'Job Definition'
    description 'This is description for the job definition.'
    script "noop:\n"
    admins { build_list(:user, 1) }
    prevent_multi false
    memory_expectancy { create_memory_expectancy! }

    factory :job_definition_with_instances do
      transient do
        job_instances_count 1
        job_instances_token_status Token::WORKING
      end

      after(:create) do |job_definition, evaluator|
        create_list(:job_instance, evaluator.job_instances_count, job_definition: job_definition)
      end
    end
  end
end
