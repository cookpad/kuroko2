FactoryBot.define do
  factory :execution, class: Kuroko2::Execution do
    shell { 'echo $NAME' }
    exit_status { 0 }

    job_definition { token ? token.job_definition : create(:job_definition) }
    job_instance { token ? token.job_instance : create(:job_instance, job_definition: job_definition) }
    context { token.context if token }

    started_at { Time.current }
    finished_at { Time.current }
  end
end
