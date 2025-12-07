# frozen_string_literal: true

# ユーザーファクトリ
# spec/factories/users.rb

FactoryBot.define do
  factory :user do
    # 基本属性
    name { Faker::Name.name }
    sequence(:email) { |n| "user#{n}@example.com" }
    password { 'password123' }
    password_confirmation { 'password123' }
    role { :member }

    # Confirmable対応
    after(:build) do |user|
      user.skip_confirmation! if user.respond_to?(:skip_confirmation!)
    end

    # トレイト: 管理者
    trait :admin do
      role { :admin }
    end

    # トレイト: 編集者
    trait :editor do
      role { :editor }
    end

    # トレイト: 未確認ユーザー
    trait :unconfirmed do
      after(:build) do |user|
        user.confirmed_at = nil if user.respond_to?(:confirmed_at=)
      end
    end

    # トレイト: ロックされたユーザー
    trait :locked do
      after(:create) do |user|
        user.lock_access! if user.respond_to?(:lock_access!)
      end
    end

    # トレイト: 記事を持つユーザー
    trait :with_articles do
      transient do
        articles_count { 3 }
      end

      after(:create) do |user, evaluator|
        create_list(:article, evaluator.articles_count, user: user)
      end
    end

    # トレイト: 公開記事を持つユーザー
    trait :with_published_articles do
      transient do
        articles_count { 3 }
      end

      after(:create) do |user, evaluator|
        create_list(:article, evaluator.articles_count, :published, user: user)
      end
    end

    # トレイト: コメントを持つユーザー
    trait :with_comments do
      transient do
        comments_count { 5 }
      end

      after(:create) do |user, evaluator|
        create_list(:comment, evaluator.comments_count, user: user)
      end
    end

    # トレイト: OmniAuth認証ユーザー
    trait :from_google do
      provider { 'google_oauth2' }
      uid { SecureRandom.uuid }
    end

    trait :from_github do
      provider { 'github' }
      uid { SecureRandom.uuid }
    end
  end
end

