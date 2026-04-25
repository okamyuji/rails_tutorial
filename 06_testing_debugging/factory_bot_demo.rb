# frozen_string_literal: true

# FactoryBotによるテストデータ管理のデモンストレーション
# rails runner factory_bot_demo.rb で実行します

puts "=" * 80
puts "FactoryBotによるテストデータ管理のデモンストレーション"
puts "=" * 80
puts ""

puts "1. FactoryBotの設定"
puts "-" * 40
puts ""

config = <<~RUBY
  # spec/support/factory_bot.rb
  RSpec.configure do |config|
    config.include FactoryBot::Syntax::Methods
  end

  # spec/rails_helper.rb に追加
  # Dir[Rails.root.join('spec/support/**/*.rb')].sort.each { |f| require f }
RUBY

puts config
puts ""

puts "2. ユーザーファクトリ"
puts "-" * 40
puts ""

user_factory = <<~RUBY
  # spec/factories/users.rb
  FactoryBot.define do
    factory :user do
      name { Faker::Name.name }
      email { Faker::Internet.unique.email }
      password { 'password123' }
      password_confirmation { 'password123' }
      role { :member }

      # 確認済みユーザー（Confirmableを使用している場合）
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
          user.confirmed_at = nil if user.respond_to?(:confirmed_at)
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

      # トレイト: コメントを持つユーザー
      trait :with_comments do
        transient do
          comments_count { 5 }
        end

        after(:create) do |user, evaluator|
          create_list(:comment, evaluator.comments_count, user: user)
        end
      end
    end
  end
RUBY

puts user_factory
puts ""

puts "3. 記事ファクトリ"
puts "-" * 40
puts ""

article_factory = <<~RUBY
  # spec/factories/articles.rb
  FactoryBot.define do
    factory :article do
      association :user
      title { Faker::Lorem.sentence(word_count: 5) }
      content { Faker::Lorem.paragraphs(number: 3).join("\\n\\n") }
      published { false }
      published_at { nil }

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
          tags = create_list(:tag, evaluator.tags_count)
          article.tags << tags
        end
      end

      # シーケンス: ユニークなタイトル
      sequence(:unique_title) { |n| "Article Title \#{n}" }

      # ファクトリ: 特定のタイトルを持つ記事
      factory :article_with_unique_title do
        title { generate(:unique_title) }
      end
    end
  end
RUBY

puts article_factory
puts ""

puts "4. コメントファクトリ"
puts "-" * 40
puts ""

comment_factory = <<~RUBY
  # spec/factories/comments.rb
  FactoryBot.define do
    factory :comment do
      association :user
      association :article
      content { Faker::Lorem.paragraph }

      # トレイト: 承認済み
      trait :approved do
        approved { true }
      end

      # トレイト: 報告済み
      trait :reported do
        reported { true }
      end

      # トレイト: 返信
      trait :reply do
        association :parent, factory: :comment
      end
    end
  end
RUBY

puts comment_factory
puts ""

puts "5. FactoryBotの使用方法"
puts "-" * 40
puts ""

usage = <<~RUBY
  # 基本的な使用方法
  user = create(:user)                    # DBに保存
  user = build(:user)                     # DBに保存しない
  attrs = attributes_for(:user)           # 属性ハッシュを取得

  # トレイトの使用
  admin = create(:user, :admin)
  published_article = create(:article, :published)

  # 複数のトレイトを組み合わせ
  featured_article = create(:article, :published, :featured, :with_comments)

  # 属性のオーバーライド
  user = create(:user, name: 'Custom Name', email: 'custom@example.com')

  # 複数作成
  users = create_list(:user, 5)
  articles = create_list(:article, 3, :published)

  # transient属性の使用
  user = create(:user, :with_articles, articles_count: 10)

  # 関連付けの指定
  article = create(:article, user: specific_user)

  # build_stubbed（DBアクセスなし、高速）
  user = build_stubbed(:user)
RUBY

puts usage
puts ""

puts "6. 高度なファクトリパターン"
puts "-" * 40
puts ""

advanced = <<~RUBY
  # シーケンス
  FactoryBot.define do
    sequence :email do |n|
      "user\#{n}@example.com"
    end

    factory :user do
      email { generate(:email) }
    end
  end

  # 継承
  FactoryBot.define do
    factory :article do
      title { 'Default Title' }

      factory :published_article do
        published { true }
        published_at { Time.current }
      end

      factory :draft_article do
        published { false }
      end
    end
  end

  # コールバック
  FactoryBot.define do
    factory :user do
      after(:build) do |user|
        # ビルド後の処理
      end

      after(:create) do |user|
        # 作成後の処理
      end

      before(:create) do |user|
        # 作成前の処理
      end
    end
  end

  # 遅延評価
  FactoryBot.define do
    factory :article do
      title { "Article by \#{user.name}" }
      created_at { 1.day.ago }
      published_at { created_at + 1.hour }
    end
  end

  # 関連付けのカスタマイズ
  FactoryBot.define do
    factory :comment do
      association :article, factory: [:article, :published]
      association :user, factory: [:user, :with_avatar]
    end
  end
RUBY

puts advanced
puts ""

puts "7. テストでの効果的な使用"
puts "-" * 40
puts ""

test_usage = <<~RUBY
  # spec/models/article_spec.rb
  RSpec.describe Article, type: :model do
    # let（遅延評価）
    let(:user) { create(:user) }
    let(:article) { create(:article, user: user) }

    # let!（即時評価）
    let!(:published_articles) { create_list(:article, 3, :published) }

    describe 'scopes' do
      # テストごとにデータを作成
      let!(:published) { create(:article, :published) }
      let!(:draft) { create(:article, published: false) }

      it 'returns published articles' do
        expect(Article.published).to include(published)
        expect(Article.published).not_to include(draft)
      end
    end

    describe '#publish!' do
      # buildで作成（DBアクセスを最小化）
      let(:article) { build(:article, published: false) }

      it 'publishes the article' do
        article.save!
        article.publish!
        expect(article.published).to be true
      end
    end

    describe 'with comments' do
      # トレイトで関連データを作成
      let(:article) { create(:article, :with_comments, comments_count: 5) }

      it 'has 5 comments' do
        expect(article.comments.count).to eq(5)
      end
    end
  end
RUBY

puts test_usage
puts ""

puts "=" * 80
puts "ベストプラクティス"
puts "=" * 80
puts ""

puts "1. buildを優先（DBアクセスを最小化）"
puts "2. トレイトで状態を表現"
puts "3. transient属性で柔軟性を確保"
puts "4. シーケンスでユニーク値を生成"
puts "5. 関連付けはassociationで明示"
puts ""

puts "=" * 80
