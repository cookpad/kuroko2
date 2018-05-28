FactoryBot.define do
  factory :script_revision, class: Kuroko2::ScriptRevision do
    job_definition { create(:job_definition) }
    user { create(:user) }
    sequence(:script) { |n| "noop:\n" * n }
    changed_at { Time.current }
  end
end
