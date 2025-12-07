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

    # トレイト: 承認済み
    trait :approved do
      approved { true } if respond_to?(:approved=)
    end

    # トレイト: 未承認
    trait :pending do
      approved { false } if respond_to?(:approved=)
    end

    # トレイト: 報告済み
    trait :reported do
      reported { true } if respond_to?(:reported=)
    end

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
      association :article, factory: [:article, :published]
    end

    # ファクトリ: 承認済みコメント
    factory :approved_comment, traits: [:approved]
  end
end

