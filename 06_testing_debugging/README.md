# 第6章：テストとデバッグ

この章では、RSpecによる自動テストとデバッグ技法を実装します。

## 前提条件

- Ruby 3.2以上
- Rails 7.2以上
- PostgreSQL

## ディレクトリ構造

```text
06_testing_debugging/
├── config/                      # 設定ファイル
│   ├── rspec.rb                # RSpec設定
│   ├── simplecov.rb            # SimpleCov設定
│   ├── factory_bot.rb          # FactoryBot設定
│   └── bullet.rb               # Bullet設定
├── factories/                   # FactoryBotファクトリ
│   ├── users.rb                # ユーザーファクトリ
│   ├── articles.rb             # 記事ファクトリ
│   └── comments.rb             # コメントファクトリ
├── spec/                        # テストファイル
│   ├── models/                 # モデルスペック
│   │   ├── user_spec.rb
│   │   ├── article_spec.rb
│   │   └── comment_spec.rb
│   ├── controllers/            # コントローラスペック
│   │   └── articles_controller_spec.rb
│   ├── requests/               # リクエストスペック
│   │   └── articles_spec.rb
│   ├── policies/               # ポリシースペック
│   │   └── article_policy_spec.rb
│   └── support/                # サポートファイル
│       ├── factory_bot.rb
│       └── shoulda_matchers.rb
├── rspec_demo.rb               # RSpecデモ
├── factory_bot_demo.rb         # FactoryBotデモ
├── debugging_demo.rb           # デバッグデモ
├── performance_demo.rb         # パフォーマンスデモ
├── README.md                   # このファイル
└── seed_data.rb                # サンプルデータ生成
```

## デモスクリプトの実行

```bash
# RSpecの概要デモ
rails runner rspec_demo.rb

# FactoryBotの詳細デモ
rails runner factory_bot_demo.rb

# デバッグ技法のデモ
rails runner debugging_demo.rb

# パフォーマンス計測のデモ
rails runner performance_demo.rb

# サンプルデータの生成
rails runner seed_data.rb
```

## 主な実装内容

### 1. RSpecによるテスト

#### インストール

```ruby
# Gemfile
group :development, :test do
  gem 'rspec-rails'
  gem 'factory_bot_rails'
  gem 'faker'
end

group :test do
  gem 'shoulda-matchers'
  gem 'database_cleaner-active_record'
end
```

```bash
bundle install
rails generate rspec:install
```

#### モデルテスト

```ruby
RSpec.describe Article, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:content) }
  end
  
  describe 'associations' do
    it { should belong_to(:user) }
    it { should have_many(:comments) }
  end
end
```

### 2. FactoryBot

```ruby
FactoryBot.define do
  factory :article do
    association :user
    title { Faker::Lorem.sentence }
    content { Faker::Lorem.paragraphs(number: 3).join("\n\n") }
    
    trait :published do
      published { true }
    end
  end
end
```

### 3. デバッグツール

```ruby
# byebug
def calculate_total
  byebug  # ここで実行が停止
  items.sum(&:price)
end
```

### 4. パフォーマンス計測

```ruby
# Bullet（N+1検出）
Bullet.enable = true
Bullet.alert = true

# rack-mini-profiler
gem 'rack-mini-profiler'
```

### 5. CIで自動失敗させる仕組み

開発時の警告に頼らず、N+1とカバレッジ低下をテスト実行で自動検出します。

- `config/bullet.rb` のテスト環境設定で `Bullet.raise = true` を有効化
- `config/simplecov.rb` で `minimum_coverage 80` / `refuse_coverage_drop` を設定
- どちらも閾値違反時にRSpecが非0 exitとなりCIが失敗する
- 詳細は[第7章のCI設定](../07_deployment_operations/github_actions/ci.yml)を参照

## テストの実行

```bash
# すべてのテストを実行
bundle exec rspec

# 特定のファイルを実行
bundle exec rspec spec/models/article_spec.rb

# 特定の行を実行
bundle exec rspec spec/models/article_spec.rb:10

# タグでフィルタリング
bundle exec rspec --tag focus
```

## ベストプラクティス

### テスト設計

1. **AAA パターン** - Arrange, Act, Assert
2. **一つのテストで一つのこと** - 単一責任
3. **テストの独立性** - 他のテストに依存しない
4. **意味のある名前** - 何をテストしているか明確に

### カバレッジ

1. **ビジネスロジック優先** - 重要な機能を優先的にテスト
2. **エッジケース** - 境界値や異常系をテスト
3. **100%を目指さない** - 質を重視
4. **閾値はCIで強制** - `minimum_coverage` で機械的に下限を担保し、目視チェックに頼らない

## 次のステップ

1. テストを実行: `bundle exec rspec`（カバレッジ閾値割れやN+1検出時は自動的に失敗）
2. カバレッジを確認: `open coverage/index.html`
3. デバッグツールを試す

次章では、デプロイと運用について学びます。
