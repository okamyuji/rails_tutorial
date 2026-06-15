FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    password { "password123" }

    trait :admin do
      role { :admin }
    end

    trait :editor do
      role { :editor }
    end

    trait :with_articles do
      after(:create) { |user| create_list(:article, 3, user: user) }
    end
  end
end
