FactoryGirl.define do
  factory :tag, class: Kuroko2::Tag do
    sequence(:name) { |n| "tag#{n}" }

    after(:create) do |tag|
      create(:job_definition, tags: [tag])
    end
  end
end
