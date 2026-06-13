# frozen_string_literal: true

# コメントファクトリ
# spec/factories/comments.rb

FactoryBot.define do
  factory :comment do
    # 関連付け
    association :user
    association :article

    # 基本属性
    content { Faker::Lorem.paragraph }

    # トレイト: 長いコメント
    trait :long do
      content { Faker::Lorem.paragraphs(number: 5).join("\n\n") }
    end

    # トレイト: 短いコメント
    trait :short do
      content { Faker::Lorem.sentence }
    end

    # トレイト: 返信コメント
    trait :reply do
      association :parent, factory: :comment
    end

    # トレイト: 古いコメント
    trait :old do
      created_at { 1.year.ago }
      updated_at { 1.year.ago }
    end

    # トレイト: 最近のコメント
    trait :recent do
      created_at { 1.hour.ago }
      updated_at { 1.hour.ago }
    end

    # トレイト: 公開記事へのコメント
    trait :on_published_article do
      association :article, factory: %i[article published]
    end

  end
end
