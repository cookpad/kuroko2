FactoryBot.define do
  factory :user, class: Kuroko2::User do
    sequence(:uid) { |n| "#{n}" }

    name { "Alice Pleasance Liddell #{uid}" }
    email { "#{uid}@example.com" }
    first_name { 'Alice' }
    last_name { 'Liddell' }
    image { 'http://example.com/alice/image' }
  end
end
