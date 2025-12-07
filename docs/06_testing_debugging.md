# 第6章：テストとデバッグ

## 6.1 RSpecによる自動テストの構築

### モデル、コントローラ、統合テストの書き方

RSpecは、Rubyのテストフレームワークです。可読性の高い構文でテストを記述できます。

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

インストールして初期化します。

```bash
bundle install
rails generate rspec:install
```

モデルのテストでは、バリデーション、関連付け、メソッドの動作を確認します。

```ruby
# spec/models/article_spec.rb
require 'rails_helper'

RSpec.describe Article, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
    it { should have_many(:comments).dependent(:destroy) }
  end
  
  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:content) }
    it { should validate_length_of(:title).is_at_least(5).is_at_most(200) }
  end
  
  describe 'scopes' do
    let!(:published_article) { create(:article, published: true) }
    let!(:draft_article) { create(:article, published: false) }
    
    it 'returns published articles' do
      expect(Article.published).to include(published_article)
      expect(Article.published).not_to include(draft_article)
    end
  end
  
  describe '#publish!' do
    let(:article) { create(:article, published: false) }
    
    it 'sets published to true' do
      article.publish!
      expect(article.published).to be true
    end
    
    it 'sets published_at to current time' do
      freeze_time do
        article.publish!
        expect(article.published_at).to eq(Time.current)
      end
    end
  end
end
```

コントローラのテストでは、HTTPリクエストとレスポンスを確認します。

```ruby
# spec/controllers/articles_controller_spec.rb
require 'rails_helper'

RSpec.describe ArticlesController, type: :controller do
  let(:user) { create(:user) }
  let(:article) { create(:article, user: user) }
  
  describe 'GET #index' do
    it 'returns a success response' do
      get :index
      expect(response).to be_successful
    end
    
    it 'assigns @articles' do
      article
      get :index
      expect(assigns(:articles)).to include(article)
    end
  end
  
  describe 'GET #show' do
    it 'returns a success response' do
      get :show, params: { id: article.id }
      expect(response).to be_successful
    end
  end
  
  describe 'POST #create' do
    context 'with valid params' do
      let(:valid_attributes) { attributes_for(:article, user_id: user.id) }
      
      it 'creates a new Article' do
        expect {
          post :create, params: { article: valid_attributes }
        }.to change(Article, :count).by(1)
      end
      
      it 'redirects to the created article' do
        post :create, params: { article: valid_attributes }
        expect(response).to redirect_to(Article.last)
      end
    end
    
    context 'with invalid params' do
      let(:invalid_attributes) { attributes_for(:article, title: '') }
      
      it 'does not create a new Article' do
        expect {
          post :create, params: { article: invalid_attributes }
        }.not_to change(Article, :count)
      end
      
      it 'renders the new template' do
        post :create, params: { article: invalid_attributes }
        expect(response).to render_template(:new)
      end
    end
  end
end
```

統合テストでは、エンドツーエンドのユーザーフローを確認します。

```ruby
# spec/requests/articles_spec.rb
require 'rails_helper'

RSpec.describe 'Articles', type: :request do
  let(:user) { create(:user) }
  let(:article) { create(:article, user: user) }
  
  describe 'GET /articles' do
    it 'returns http success' do
      get articles_path
      expect(response).to have_http_status(:success)
    end
    
    it 'displays articles' do
      article
      get articles_path
      expect(response.body).to include(article.title)
    end
  end
  
  describe 'POST /articles' do
    let(:valid_params) { { article: attributes_for(:article, user_id: user.id) } }
    
    it 'creates a new article' do
      expect {
        post articles_path, params: valid_params
      }.to change(Article, :count).by(1)
    end
    
    it 'returns http redirect' do
      post articles_path, params: valid_params
      expect(response).to have_http_status(:redirect)
    end
  end
end
```

### FactoryBotでテストデータを効率的に管理

FactoryBotは、テストデータを簡潔に定義できます。

```ruby
# spec/factories/users.rb
FactoryBot.define do
  factory :user do
    name { Faker::Name.name }
    email { Faker::Internet.email }
    password { 'password123' }
    
    trait :admin do
      role { :admin }
    end
    
    trait :with_articles do
      after(:create) do |user|
        create_list(:article, 3, user: user)
      end
    end
  end
end
```

```ruby
# spec/factories/articles.rb
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
  end
end
```

テストで使用します。

```ruby
# 基本的な使用
user = create(:user)
article = create(:article)

# traitの使用
admin = create(:user, :admin)
published_article = create(:article, :published)

# 複数作成
articles = create_list(:article, 5)

# 属性のオーバーライド
article = create(:article, title: 'Custom Title')

# buildはDBに保存しない
article = build(:article)

# attributes_forは属性ハッシュを返す
attrs = attributes_for(:article)
```

### テストカバレッジを計測する意義

SimpleCovは、テストカバレッジを計測します。

```ruby
# Gemfile
group :test do
  gem 'simplecov', require: false
end
```

```ruby
# spec/spec_helper.rb
require 'simplecov'
SimpleCov.start 'rails' do
  add_filter '/bin/'
  add_filter '/db/'
  add_filter '/spec/'
end
```

テストを実行すると、`coverage`ディレクトリにレポートが生成されます。

```bash
bundle exec rspec
open coverage/index.html
```

カバレッジ100%を目指すべきかは議論があります。重要なのは、ビジネスロジックが適切にテストされていることです。

カバレッジが低い箇所は、テストが不足している可能性があります。ただし、カバレッジが高くてもテストの質が保証されるわけではありません。

効果的なテスト戦略は、以下の優先順位で作成します。

モデルのビジネスロジックは、最も重要です。計算、状態遷移、複雑なバリデーションなどをテストします。

統合テストは、ユーザーフローを保証します。重要な機能パスをカバーします。

コントローラテストは、必要に応じて作成します。統合テストで十分な場合もあります。

ビューのテストは、複雑なロジックがある場合のみ作成します。

## 6.2 デバッグ技法とパフォーマンス計測

### byebugとデバッグツールの効果的な使い方

byebugは、Rubyのデバッガです。コードの実行を一時停止し、変数の値を確認できます。

```ruby
def calculate_total
  items = fetch_items
  byebug  # ここで実行が停止
  items.sum(&:price)
end
```

デバッガが起動すると、対話的にコマンドを実行できます。

```shell
(byebug) items
[#<Item id: 1, price: 100>, #<Item id: 2, price: 200>]

(byebug) items.sum(&:price)
300

(byebug) next  # 次の行に進む
(byebug) step  # メソッドの中に入る
(byebug) continue  # 実行を再開
```

主要なコマンドを以下に示します。

`next`は、次の行に進みます。メソッド呼び出しはステップオーバーします。

`step`は、メソッドの中に入ります。詳細な実行を追跡できます。

`continue`は、次のブレークポイントまで実行を再開します。

`list`は、現在の行周辺のコードを表示します。

`var local`は、ローカル変数を表示します。

`var instance`は、インスタンス変数を表示します。

条件付きブレークポイントも設定できます。

```ruby
def process_items
  items.each do |item|
    byebug if item.price > 1000  # 高額商品のみでデバッグ
    process(item)
  end
end
```

Rails ConsoleでもByebugを使用できます。

```ruby
rails console

> article = Article.first
> byebug
> article.publish!
```

### Bullet gemでN+1問題を検出する

Bulletは、N+1問題を自動検出します。

```ruby
# Gemfile
group :development do
  gem 'bullet'
end
```

```ruby
# config/environments/development.rb
config.after_initialize do
  Bullet.enable = true
  Bullet.alert = true
  Bullet.bullet_logger = true
  Bullet.console = true
  Bullet.rails_logger = true
end
```

N+1問題が検出されると、警告が表示されます。

```ruby
USE eager loading detected
  Article => [:user]
  Add to your query: .includes([:user])
```

Bulletの警告に従って、`includes`を追加します。

```ruby
# 修正前
@articles = Article.all
@articles.each { |article| puts article.user.name }

# 修正後
@articles = Article.includes(:user).all
@articles.each { |article| puts article.user.name }
```

### rack-mini-profilerでボトルネックを特定

rack-mini-profilerは、各リクエストのパフォーマンスを可視化します。

```ruby
# Gemfile
group :development do
  gem 'rack-mini-profiler'
  gem 'memory_profiler'
  gem 'stackprof'
end
```

サーバーを起動すると、ページの左上に実行時間が表示されます。クリックすると詳細が確認できます。

SQLクエリの実行時間、ビューのレンダリング時間などが分かります。遅い処理を特定して最適化できます。

プロファイルを無効化する場合は、URLパラメータを追加します。

```text
http://localhost:3000/articles?pp=disable
```

特定の処理をプロファイルする場合は、コードに追加します。

```ruby
Rack::MiniProfiler.step("Fetch articles") do
  @articles = Article.includes(:user, :comments).limit(100)
end
```

メモリプロファイルも実行できます。

```ruby
# URLに ?pp=profile-memory を追加
```

フレームグラフで実行時間の内訳を可視化できます。

```ruby
# URLに ?pp=flamegraph を追加
```

## まとめ

この章では、テストとデバッグについて学びました。

RSpecは、モデル、コントローラ、統合テストを記述できます。FactoryBotでテストデータを効率的に管理し、SimpleCovでカバレッジを計測します。テストは、ビジネスロジックを優先的にカバーすべきです。

byebugは、コードの実行を一時停止してデバッグできます。変数の値を確認し、ステップ実行で問題を特定します。

BulletはN+1問題を自動検出し、rack-mini-profilerはボトルネックを可視化します。これらのツールを活用することで、パフォーマンスの高いアプリケーションを構築できます。

次章では、デプロイと運用について学びます。本番環境への移行、継続的インテグレーション、監視とログ管理を習得します。
