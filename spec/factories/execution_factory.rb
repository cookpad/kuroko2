FactoryGirl.define do
  factory :execution, class: Kuroko2::Execution do
    shell 'echo $NAME'
    exit_status 0

    job_definition { token.job_definition if token }
    job_instance { token.job_instance if token }
    context { token.context if token }

    started_at { Time.now }
    finished_at { Time.now }
  end
end
