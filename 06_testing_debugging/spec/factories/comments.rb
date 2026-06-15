FactoryBot.define do
  factory :comment do
    association :user
    association :article
    content { Faker::Lorem.paragraph }
  end
end
