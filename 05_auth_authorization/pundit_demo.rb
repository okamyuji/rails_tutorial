# frozen_string_literal: true

# Punditによる権限管理のデモンストレーション
# rails runner pundit_demo.rb で実行します

puts "=" * 80
puts "Punditによる権限管理のデモンストレーション"
puts "=" * 80
puts ""

puts "1. Punditの概要"
puts "-" * 40
puts ""

overview = <<~TEXT
  Punditは、権限管理を宣言的に記述するgemです。

  特徴:
  - ポリシークラスに権限ロジックを集約
  - シンプルなRubyオブジェクト（PORO）
  - テストが容易
  - コントローラとビューで一貫した権限チェック

  設計原則:
  - 各モデルに対応するポリシークラスを作成
  - ポリシーメソッドは真偽値を返す
  - Scopeで表示可能なレコードをフィルタリング
TEXT

puts overview
puts ""

puts "2. インストールと設定"
puts "-" * 40
puts ""

installation = <<~RUBY
  # Gemfile
  gem 'pundit'
RUBY

puts installation
puts ""

puts "■ ApplicationControllerへの組み込み:"
puts ""

app_controller = <<~RUBY
  # app/controllers/application_controller.rb
  class ApplicationController < ActionController::Base
    include Pundit::Authorization

    # 権限エラーのハンドリング
    rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

    # すべてのアクションで権限チェックを強制（オプション）
    # after_action :verify_authorized, except: :index
    # after_action :verify_policy_scoped, only: :index

    private

    def user_not_authorized
      flash[:alert] = "You are not authorized to perform this action."
      redirect_back(fallback_location: root_path)
    end
  end
RUBY

puts app_controller
puts ""

puts "3. 基底ポリシークラス"
puts "-" * 40
puts ""

application_policy = <<~RUBY
  # app/policies/application_policy.rb
  class ApplicationPolicy
    attr_reader :user, :record

    def initialize(user, record)
      @user = user
      @record = record
    end

    # デフォルトではすべて拒否
    def index?
      false
    end

    def show?
      false
    end

    def create?
      false
    end

    def new?
      create?
    end

    def update?
      false
    end

    def edit?
      update?
    end

    def destroy?
      false
    end

    # スコープクラス
    class Scope
      attr_reader :user, :scope

      def initialize(user, scope)
        @user = user
        @scope = scope
      end

      def resolve
        raise NotImplementedError, "You must define #resolve in \#{self.class}"
      end

      private

      def admin?
        user&.admin?
      end

      def editor?
        user&.editor? || admin?
      end
    end
  end
RUBY

puts application_policy
puts ""

puts "4. 記事ポリシーの例"
puts "-" * 40
puts ""

article_policy = <<~RUBY
  # app/policies/article_policy.rb
  class ArticlePolicy < ApplicationPolicy
    # 誰でも一覧を表示できる
    def index?
      true
    end

    # 公開記事は誰でも閲覧可能、下書きは作者と管理者のみ
    def show?
      record.published? || owner? || admin?
    end

    # ログインユーザーのみ作成可能
    def create?
      user.present?
    end

    # 作者または管理者のみ更新可能
    def update?
      owner? || admin?
    end

    # 作者または管理者のみ削除可能
    def destroy?
      owner? || admin?
    end

    # 作者、編集者、管理者のみ公開可能
    def publish?
      owner? || editor? || admin?
    end

    # 作者、編集者、管理者のみ非公開可能
    def unpublish?
      owner? || editor? || admin?
    end

    # 許可される属性（Strong Parametersと連携）
    def permitted_attributes
      if admin?
        [:title, :content, :published, :featured, :category_id, tag_ids: []]
      elsif editor?
        [:title, :content, :published, :category_id, tag_ids: []]
      else
        [:title, :content]
      end
    end

    # 許可される属性（作成時）
    def permitted_attributes_for_create
      [:title, :content, :category_id, tag_ids: []]
    end

    # 許可される属性（更新時）
    def permitted_attributes_for_update
      permitted_attributes
    end

    # スコープ
    class Scope < Scope
      def resolve
        if admin?
          # 管理者はすべての記事を表示
          scope.all
        elsif user.present?
          # ログインユーザーは公開記事と自分の記事を表示
          scope.where(published: true).or(scope.where(user: user))
        else
          # 未ログインユーザーは公開記事のみ表示
          scope.where(published: true)
        end
      end
    end

    private

    def owner?
      user.present? && record.user == user
    end

    def admin?
      user&.admin?
    end

    def editor?
      user&.editor? || admin?
    end
  end
RUBY

puts article_policy
puts ""

puts "5. コメントポリシーの例"
puts "-" * 40
puts ""

comment_policy = <<~RUBY
  # app/policies/comment_policy.rb
  class CommentPolicy < ApplicationPolicy
    def index?
      true
    end

    def show?
      true
    end

    def create?
      user.present?
    end

    def update?
      owner? || admin?
    end

    def destroy?
      owner? || article_owner? || admin?
    end

    class Scope < Scope
      def resolve
        scope.all
      end
    end

    private

    def owner?
      user.present? && record.user == user
    end

    def article_owner?
      user.present? && record.article.user == user
    end

    def admin?
      user&.admin?
    end
  end
RUBY

puts comment_policy
puts ""

puts "6. コントローラでの使用"
puts "-" * 40
puts ""

controller_usage = <<~RUBY
  # app/controllers/articles_controller.rb
  class ArticlesController < ApplicationController
    before_action :authenticate_user!, except: [:index, :show]
    before_action :set_article, only: [:show, :edit, :update, :destroy, :publish, :unpublish]

    def index
      # policy_scopeで表示可能な記事のみ取得
      @articles = policy_scope(Article).order(created_at: :desc)
    end

    def show
      # 権限チェック
      authorize @article
    end

    def new
      @article = Article.new
      # 新規作成の権限チェック
      authorize @article
    end

    def create
      @article = current_user.articles.build(article_params)
      authorize @article

      if @article.save
        redirect_to @article, notice: 'Article was successfully created.'
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      authorize @article
    end

    def update
      authorize @article

      if @article.update(article_params)
        redirect_to @article, notice: 'Article was successfully updated.'
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize @article
      @article.destroy
      redirect_to articles_url, notice: 'Article was successfully destroyed.'
    end

    def publish
      authorize @article
      @article.update!(published: true, published_at: Time.current)
      redirect_to @article, notice: 'Article was published.'
    end

    def unpublish
      authorize @article
      @article.update!(published: false, published_at: nil)
      redirect_to @article, notice: 'Article was unpublished.'
    end

    private

    def set_article
      @article = Article.find(params[:id])
    end

    # ポリシーで許可された属性を使用
    def article_params
      params.require(:article).permit(policy(@article || Article).permitted_attributes)
    end
  end
RUBY

puts controller_usage
puts ""

puts "7. ビューでの使用"
puts "-" * 40
puts ""

view_usage = <<~ERB
  <%# app/views/articles/index.html.erb %>
  <h1>Articles</h1>

  <%# 新規作成ボタン（権限がある場合のみ表示） %>
  <% if policy(Article).create? %>
    <%= link_to 'New Article', new_article_path, class: 'btn btn-primary' %>
  <% end %>

  <% @articles.each do |article| %>
    <article>
      <h2><%= link_to article.title, article %></h2>
      <p><%= article.user.name %> - <%= article.created_at.strftime('%Y-%m-%d') %></p>
  #{"    "}
      <div class="actions">
        <%# 編集ボタン %>
        <% if policy(article).edit? %>
          <%= link_to 'Edit', edit_article_path(article), class: 'btn btn-secondary' %>
        <% end %>
  #{"      "}
        <%# 削除ボタン %>
        <% if policy(article).destroy? %>
          <%= button_to 'Delete', article, method: :delete,#{" "}
                        data: { turbo_confirm: 'Are you sure?' },
                        class: 'btn btn-danger' %>
        <% end %>
  #{"      "}
        <%# 公開/非公開ボタン %>
        <% if policy(article).publish? %>
          <% if article.published? %>
            <%= button_to 'Unpublish', unpublish_article_path(article),#{" "}
                          method: :post, class: 'btn btn-warning' %>
          <% else %>
            <%= button_to 'Publish', publish_article_path(article),#{" "}
                          method: :post, class: 'btn btn-success' %>
          <% end %>
        <% end %>
      </div>
    </article>
  <% end %>
ERB

puts view_usage
puts ""

puts "8. ロールベースとリソースベースの権限"
puts "-" * 40
puts ""

role_resource = <<~RUBY
  # ロールベース：ユーザーの役割に基づく権限
  class User < ApplicationRecord
    enum role: { member: 0, editor: 1, admin: 2 }
  end

  class ArticlePolicy < ApplicationPolicy
    def update?
      # 管理者は何でも更新可能
      return true if user.admin?
  #{"    "}
      # 編集者は公開記事を更新可能
      return true if user.editor? && record.published?
  #{"    "}
      # 作者は自分の記事を更新可能
      record.user == user
    end
  end

  # リソースベース：個別のリソースに対する権限
  class Permission < ApplicationRecord
    belongs_to :user
    belongs_to :resource, polymorphic: true

    enum action: { read: 0, write: 1, delete: 2, admin: 3 }
  end

  class ArticlePolicy < ApplicationPolicy
    def update?
      # 管理者は常に許可
      return true if user.admin?

      # 作者は許可
      return true if record.user == user

      # 個別の権限をチェック
      Permission.exists?(
        user: user,
        resource: record,
        action: [:write, :admin]
      )
    end
  end
RUBY

puts role_resource
puts ""

puts "9. ポリシーのテスト"
puts "-" * 40
puts ""

policy_test = <<~RUBY
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

        it { is_expected.to permit_action(:index) }
        it { is_expected.to permit_action(:show) }
        it { is_expected.to permit_action(:create) }
        it { is_expected.to permit_action(:update) }
        it { is_expected.to permit_action(:destroy) }
      end

      context 'for an admin user' do
        let(:user) { create(:user, :admin) }

        it { is_expected.to permit_action(:index) }
        it { is_expected.to permit_action(:show) }
        it { is_expected.to permit_action(:create) }
        it { is_expected.to permit_action(:update) }
        it { is_expected.to permit_action(:destroy) }
      end

      context 'for a different user' do
        let(:user) { create(:user) }

        it { is_expected.to permit_action(:index) }
        it { is_expected.to permit_action(:show) }
        it { is_expected.to permit_action(:create) }
        it { is_expected.not_to permit_action(:update) }
        it { is_expected.not_to permit_action(:destroy) }
      end
    end

    describe 'scope' do
      let!(:published_article) { create(:article, published: true) }
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

      context 'for a guest user' do
        let(:user) { nil }

        it 'includes only published articles' do
          expect(subject).to include(published_article)
          expect(subject).not_to include(draft_article)
        end
      end
    end

    describe 'permitted_attributes' do
      context 'for an admin user' do
        let(:user) { create(:user, :admin) }

        it 'includes all attributes' do
          expect(subject.permitted_attributes).to include(:title, :content, :published, :featured)
        end
      end

      context 'for a regular user' do
        let(:user) { create(:user) }

        it 'includes only basic attributes' do
          expect(subject.permitted_attributes).to eq([:title, :content])
        end
      end
    end
  end
RUBY

puts policy_test
puts ""

puts "=" * 80
puts "ベストプラクティス"
puts "=" * 80
puts ""

puts "1. ポリシーの設計:"
puts "   - 各モデルに対応するポリシーを作成"
puts "   - 権限ロジックをポリシーに集約"
puts "   - コントローラとビューで一貫した権限チェック"
puts ""

puts "2. テスト:"
puts "   - すべての権限パターンをテスト"
puts "   - Scopeのテストも忘れずに"
puts "   - エッジケースを考慮"
puts ""

puts "3. パフォーマンス:"
puts "   - N+1問題に注意（権限チェックでDBクエリが発生する場合）"
puts "   - 必要に応じてキャッシュを使用"
puts ""

puts "4. セキュリティ:"
puts "   - デフォルトで拒否（明示的に許可）"
puts "   - 最小権限の原則"
puts "   - 権限エラーのログ記録"
puts ""

puts "=" * 80
