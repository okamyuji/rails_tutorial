FactoryBot.define do
  factory :comment do
    association :user
    association :article
    body { Faker::Lorem.paragraph }
  end
end
