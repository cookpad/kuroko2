FactoryBot.define do
  factory :execution_history, class: Kuroko2::ExecutionHistory do
    hostname 'rspec'
    worker_id 1
    queue '@default'

    job_definition { create(:job_definition) }
    job_instance { create(:job_instance, job_definition: job_definition) }

    shell 'echo $NAME'

    started_at { Time.current }
    finished_at { Time.current }
  end
end
