FactoryBot.define do
  factory :article do
    association :user
    title { Faker::Lorem.sentence }
    content { Faker::Lorem.paragraphs(number: 3).join("\n\n") }
    published { false }

    trait :published do
      published { true }
      published_at { Time.current }
    end

    after(:build) do |article|
      if article.published? && article.published_at.nil?
        article.published_at = Time.current
      end
    end
  end
end
