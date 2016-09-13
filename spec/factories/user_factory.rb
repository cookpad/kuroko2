FactoryGirl.define do
  factory :user, class: Kuroko2::User do
    sequence(:uid) { |n| "#{n}#{Time.now.to_i}#{rand(100000)}" }

    name { "Alice Pleasance Liddell #{uid}" }
    email { "#{uid}@example.com" }
    first_name 'Alice'
    last_name { "Liddell #{uid}" }
    image 'http://example.com/alice/image'
  end
end
