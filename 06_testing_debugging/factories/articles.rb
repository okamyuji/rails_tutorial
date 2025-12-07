# frozen_string_literal: true

# 記事ファクトリ
# spec/factories/articles.rb

FactoryBot.define do
  factory :article do
    # 関連付け
    association :user

    # 基本属性
    sequence(:title) { |n| "Article Title #{n}" }
    content { Faker::Lorem.paragraphs(number: 3).join("\n\n") }
    published { false }
    published_at { nil }
    featured { false }

    # トレイト: 公開済み
    trait :published do
      published { true }
      published_at { Time.current }
    end

    # トレイト: フィーチャー記事
    trait :featured do
      published
      featured { true }
    end

    # トレイト: 下書き
    trait :draft do
      published { false }
      published_at { nil }
    end

    # トレイト: 古い記事
    trait :old do
      created_at { 1.year.ago }
      updated_at { 1.year.ago }
    end

    # トレイト: 最近の記事
    trait :recent do
      created_at { 1.day.ago }
      updated_at { 1.day.ago }
    end

    # トレイト: 長いコンテンツ
    trait :long_content do
      content { Faker::Lorem.paragraphs(number: 20).join("\n\n") }
    end

    # トレイト: 短いコンテンツ
    trait :short_content do
      content { Faker::Lorem.sentence }
    end

    # トレイト: コメント付き
    trait :with_comments do
      transient do
        comments_count { 3 }
      end

      after(:create) do |article, evaluator|
        create_list(:comment, evaluator.comments_count, article: article)
      end
    end

    # トレイト: タグ付き
    trait :with_tags do
      transient do
        tags_count { 2 }
      end

      after(:create) do |article, evaluator|
        if article.respond_to?(:tags)
          tags = create_list(:tag, evaluator.tags_count)
          article.tags << tags
        end
      end
    end

    # トレイト: 特定のユーザーの記事
    trait :by_admin do
      association :user, factory: [:user, :admin]
    end

    trait :by_editor do
      association :user, factory: [:user, :editor]
    end

    # ファクトリ: 公開記事
    factory :published_article, traits: [:published]

    # ファクトリ: フィーチャー記事
    factory :featured_article, traits: [:featured]

    # ファクトリ: コメント付き公開記事
    factory :published_article_with_comments, traits: [:published, :with_comments]
  end
end

