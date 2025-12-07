# frozen_string_literal: true

# RSpecによる自動テストのデモンストレーション
# rails runner rspec_demo.rb で実行します

puts '=' * 80
puts 'RSpecによる自動テストのデモンストレーション'
puts '=' * 80
puts ''

puts '1. RSpecのインストール'
puts '-' * 40
puts ''

gemfile = <<~RUBY
# Gemfile
group :development, :test do
  gem 'rspec-rails'
  gem 'factory_bot_rails'
  gem 'faker'
end

group :test do
  gem 'shoulda-matchers'
  gem 'database_cleaner-active_record'
  gem 'simplecov', require: false
end
RUBY

puts gemfile
puts ''

install_commands = <<~BASH
bundle install
rails generate rspec:install
BASH

puts '■ インストールコマンド:'
puts install_commands
puts ''

puts '2. RSpecの設定'
puts '-' * 40
puts ''

spec_helper = <<~RUBY
# spec/spec_helper.rb
require 'simplecov'
SimpleCov.start 'rails' do
  add_filter '/bin/'
  add_filter '/db/'
  add_filter '/spec/'
  
  add_group 'Models', 'app/models'
  add_group 'Controllers', 'app/controllers'
  add_group 'Policies', 'app/policies'
  add_group 'Services', 'app/services'
end

RSpec.configure do |config|
  # 期待値の構文
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  # モックの構文
  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  # 共有コンテキスト
  config.shared_context_metadata_behavior = :apply_to_host_groups

  # フィルタリング
  config.filter_run_when_matching :focus

  # 出力フォーマット
  config.default_formatter = 'doc' if config.files_to_run.one?

  # プロファイリング
  config.profile_examples = 10

  # ランダム実行
  config.order = :random
  Kernel.srand config.seed
end
RUBY

puts spec_helper
puts ''

rails_helper = <<~RUBY
# spec/rails_helper.rb
require 'spec_helper'
ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'

abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'

Dir[Rails.root.join('spec/support/**/*.rb')].sort.each { |f| require f }

begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  abort e.to_s.strip
end

RSpec.configure do |config|
  config.fixture_paths = [Rails.root.join('spec/fixtures')]
  config.use_transactional_fixtures = true
  config.infer_spec_type_from_file_location!
  config.filter_rails_from_backtrace!

  # FactoryBot
  config.include FactoryBot::Syntax::Methods

  # Devise
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Devise::Test::IntegrationHelpers, type: :request
end
RUBY

puts rails_helper
puts ''

puts '3. モデルテスト'
puts '-' * 40
puts ''

model_spec = <<~RUBY
# spec/models/article_spec.rb
require 'rails_helper'

RSpec.describe Article, type: :model do
  # 関連付けのテスト
  describe 'associations' do
    it { should belong_to(:user) }
    it { should have_many(:comments).dependent(:destroy) }
    it { should have_many(:taggings) }
    it { should have_many(:tags).through(:taggings) }
  end

  # バリデーションのテスト
  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:content) }
    it { should validate_length_of(:title).is_at_least(5).is_at_most(200) }
  end

  # スコープのテスト
  describe 'scopes' do
    let!(:published_article) { create(:article, :published) }
    let!(:draft_article) { create(:article, published: false) }

    describe '.published' do
      it 'returns only published articles' do
        expect(Article.published).to include(published_article)
        expect(Article.published).not_to include(draft_article)
      end
    end

    describe '.recent' do
      let!(:old_article) { create(:article, :published, created_at: 1.month.ago) }
      let!(:new_article) { create(:article, :published, created_at: 1.day.ago) }

      it 'returns articles ordered by created_at desc' do
        expect(Article.recent.first).to eq(new_article)
      end
    end
  end

  # インスタンスメソッドのテスト
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

  describe '#draft?' do
    context 'when article is not published' do
      let(:article) { build(:article, published: false) }

      it 'returns true' do
        expect(article.draft?).to be true
      end
    end

    context 'when article is published' do
      let(:article) { build(:article, :published) }

      it 'returns false' do
        expect(article.draft?).to be false
      end
    end
  end

  # コールバックのテスト
  describe 'callbacks' do
    describe 'before_save' do
      let(:article) { build(:article, title: '  Test Title  ') }

      it 'strips whitespace from title' do
        article.save
        expect(article.title).to eq('Test Title')
      end
    end
  end
end
RUBY

puts model_spec
puts ''

puts '4. コントローラテスト'
puts '-' * 40
puts ''

controller_spec = <<~RUBY
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

    it 'assigns the requested article' do
      get :show, params: { id: article.id }
      expect(assigns(:article)).to eq(article)
    end
  end

  describe 'POST #create' do
    before { sign_in user }

    context 'with valid params' do
      let(:valid_attributes) { attributes_for(:article) }

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

  describe 'PUT #update' do
    before { sign_in user }

    context 'with valid params' do
      let(:new_attributes) { { title: 'Updated Title' } }

      it 'updates the requested article' do
        put :update, params: { id: article.id, article: new_attributes }
        article.reload
        expect(article.title).to eq('Updated Title')
      end
    end
  end

  describe 'DELETE #destroy' do
    before { sign_in user }

    it 'destroys the requested article' do
      article
      expect {
        delete :destroy, params: { id: article.id }
      }.to change(Article, :count).by(-1)
    end
  end
end
RUBY

puts controller_spec
puts ''

puts '5. リクエストテスト（統合テスト）'
puts '-' * 40
puts ''

request_spec = <<~RUBY
# spec/requests/articles_spec.rb
require 'rails_helper'

RSpec.describe 'Articles', type: :request do
  let(:user) { create(:user) }
  let(:article) { create(:article, user: user) }

  describe 'GET /articles' do
    before { create_list(:article, 3, :published) }

    it 'returns http success' do
      get articles_path
      expect(response).to have_http_status(:success)
    end

    it 'displays articles' do
      get articles_path
      expect(response.body).to include(Article.first.title)
    end
  end

  describe 'GET /articles/:id' do
    it 'returns http success' do
      get article_path(article)
      expect(response).to have_http_status(:success)
    end

    it 'displays the article' do
      get article_path(article)
      expect(response.body).to include(article.title)
    end
  end

  describe 'POST /articles' do
    before { sign_in user }

    let(:valid_params) { { article: attributes_for(:article) } }

    it 'creates a new article' do
      expect {
        post articles_path, params: valid_params
      }.to change(Article, :count).by(1)
    end

    it 'redirects to the created article' do
      post articles_path, params: valid_params
      expect(response).to redirect_to(Article.last)
    end
  end

  describe 'authentication' do
    context 'when not logged in' do
      it 'redirects to login page for create' do
        post articles_path, params: { article: attributes_for(:article) }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
RUBY

puts request_spec
puts ''

puts '6. ポリシーテスト'
puts '-' * 40
puts ''

policy_spec = <<~RUBY
# spec/policies/article_policy_spec.rb
require 'rails_helper'

RSpec.describe ArticlePolicy do
  subject { described_class.new(user, article) }

  let(:article) { create(:article) }

  describe 'permissions' do
    context 'for a guest user' do
      let(:user) { nil }

      it { is_expected.to permit_action(:index) }
      it { is_expected.to permit_action(:show) }
      it { is_expected.not_to permit_action(:create) }
      it { is_expected.not_to permit_action(:update) }
      it { is_expected.not_to permit_action(:destroy) }
    end

    context 'for the article owner' do
      let(:user) { article.user }

      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
    end

    context 'for an admin user' do
      let(:user) { create(:user, :admin) }

      it { is_expected.to permit_action(:update) }
      it { is_expected.to permit_action(:destroy) }
    end

    context 'for a different user' do
      let(:user) { create(:user) }

      it { is_expected.not_to permit_action(:update) }
      it { is_expected.not_to permit_action(:destroy) }
    end
  end

  describe 'scope' do
    let!(:published_article) { create(:article, :published) }
    let!(:draft_article) { create(:article, published: false) }

    subject { ArticlePolicy::Scope.new(user, Article).resolve }

    context 'for an admin user' do
      let(:user) { create(:user, :admin) }

      it 'includes all articles' do
        expect(subject).to include(published_article, draft_article)
      end
    end

    context 'for a regular user' do
      let(:user) { create(:user) }

      it 'includes only published articles' do
        expect(subject).to include(published_article)
        expect(subject).not_to include(draft_article)
      end
    end
  end
end
RUBY

puts policy_spec
puts ''

puts '=' * 80
puts 'テストの実行コマンド'
puts '=' * 80
puts ''

puts '# すべてのテストを実行'
puts 'bundle exec rspec'
puts ''
puts '# 特定のファイルを実行'
puts 'bundle exec rspec spec/models/article_spec.rb'
puts ''
puts '# 特定の行を実行'
puts 'bundle exec rspec spec/models/article_spec.rb:10'
puts ''
puts '# タグでフィルタリング'
puts 'bundle exec rspec --tag focus'
puts ''
puts '# フォーマットを指定'
puts 'bundle exec rspec --format documentation'
puts ''

puts '=' * 80

