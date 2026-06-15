FactoryBot.define do
  factory :article do
    association :user
    title { Faker::Lorem.sentence(word_count: 5) }
    content { Faker::Lorem.paragraphs(number: 3).join("\n\n") }
    published { false }

    trait :published do
      published { true }
      published_at { Time.current }
    end
  end
end
