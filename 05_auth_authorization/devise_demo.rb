# frozen_string_literal: true

# Deviseによるユーザー認証のデモンストレーション
# rails runner devise_demo.rb で実行します

puts "=" * 80
puts "Deviseによるユーザー認証のデモンストレーション"
puts "=" * 80
puts ""

puts "1. Deviseのインストール"
puts "-" * 40
puts ""

puts "■ Gemfileに追加:"
puts ""

gemfile_example = <<~RUBY
  # Gemfile
  gem 'devise'
RUBY

puts gemfile_example
puts ""

puts "■ インストールコマンド:"
puts ""

install_commands = <<~BASH
  bundle install
  rails generate devise:install
  rails generate devise User
  rails db:migrate
BASH

puts install_commands
puts ""

puts "2. Deviseのモジュール"
puts "-" * 40
puts ""

modules_info = <<~TEXT
  Deviseは10のモジュールを提供します:

  1. Database Authenticatable（必須）
     - メールアドレスとパスワードによる認証
     - パスワードはbcryptでハッシュ化

  2. Registerable
     - ユーザー登録機能
     - アカウント編集・削除

  3. Recoverable
     - パスワードリセット機能
     - メールでリセットリンクを送信

  4. Rememberable
     - 「ログイン状態を保持する」機能
     - Cookieでセッションを永続化

  5. Trackable
     - ログイン回数の記録
     - 最終ログイン日時の記録
     - IPアドレスの記録

  6. Validatable
     - メールアドレスのバリデーション
     - パスワードのバリデーション

  7. Confirmable
     - メールアドレス確認機能
     - 登録後に確認メールを送信

  8. Lockable
     - アカウントロック機能
     - 一定回数ログイン失敗でロック

  9. Timeoutable
     - セッションタイムアウト
     - 一定時間操作がないと自動ログアウト

  10. Omniauthable
      - 外部認証プロバイダとの連携
      - Google、Facebook、GitHubなど
TEXT

puts modules_info
puts ""

puts "3. Userモデルの設定"
puts "-" * 40
puts ""

user_model = <<~RUBY
  # app/models/user.rb
  class User < ApplicationRecord
    # 使用するモジュールを指定
    devise :database_authenticatable, :registerable,
           :recoverable, :rememberable, :validatable,
           :confirmable, :trackable, :lockable, :timeoutable

    # 追加の属性
    enum role: { member: 0, editor: 1, admin: 2 }

    # 関連付け
    has_many :articles, dependent: :destroy
    has_many :comments, dependent: :destroy

    # バリデーション
    validates :name, presence: true, length: { minimum: 2, maximum: 50 }

    # コールバック
    after_initialize :set_default_role, if: :new_record?

    private

    def set_default_role
      self.role ||= :member
    end
  end
RUBY

puts user_model
puts ""

puts "4. マイグレーションファイル"
puts "-" * 40
puts ""

migration_example = <<~RUBY
  # db/migrate/XXXXXX_devise_create_users.rb
  class DeviseCreateUsers < ActiveRecord::Migration[7.2]
    def change
      create_table :users do |t|
        ## Database authenticatable
        t.string :email,              null: false, default: ""
        t.string :encrypted_password, null: false, default: ""

        ## Recoverable
        t.string   :reset_password_token
        t.datetime :reset_password_sent_at

        ## Rememberable
        t.datetime :remember_created_at

        ## Trackable
        t.integer  :sign_in_count, default: 0, null: false
        t.datetime :current_sign_in_at
        t.datetime :last_sign_in_at
        t.string   :current_sign_in_ip
        t.string   :last_sign_in_ip

        ## Confirmable
        t.string   :confirmation_token
        t.datetime :confirmed_at
        t.datetime :confirmation_sent_at
        t.string   :unconfirmed_email

        ## Lockable
        t.integer  :failed_attempts, default: 0, null: false
        t.string   :unlock_token
        t.datetime :locked_at

        ## カスタム属性
        t.string :name
        t.integer :role, default: 0

        t.timestamps null: false
      end

      add_index :users, :email,                unique: true
      add_index :users, :reset_password_token, unique: true
      add_index :users, :confirmation_token,   unique: true
      add_index :users, :unlock_token,         unique: true
    end
  end
RUBY

puts migration_example
puts ""

puts "5. コントローラでの認証"
puts "-" * 40
puts ""

controller_auth = <<~RUBY
  # app/controllers/application_controller.rb
  class ApplicationController < ActionController::Base
    # すべてのコントローラで認証を要求する場合
    # before_action :authenticate_user!
  end

  # app/controllers/articles_controller.rb
  class ArticlesController < ApplicationController
    # このコントローラのすべてのアクションで認証を要求
    before_action :authenticate_user!

    # または特定のアクションのみ
    before_action :authenticate_user!, only: [:create, :update, :destroy]
    before_action :authenticate_user!, except: [:index, :show]

    def index
      @articles = Article.all
    end

    def create
      @article = current_user.articles.build(article_params)
      # ...
    end
  end
RUBY

puts controller_auth
puts ""

puts "6. ビューでのヘルパーメソッド"
puts "-" * 40
puts ""

view_helpers = <<~ERB
  <%# ログイン状態の確認 %>
  <% if user_signed_in? %>
    <p>Welcome, <%= current_user.email %>!</p>
    <p>Name: <%= current_user.name %></p>
  #{"  "}
    <%# ログアウトリンク %>
    <%= button_to "Sign out", destroy_user_session_path, method: :delete %>
  <% else %>
    <%# ログイン・登録リンク %>
    <%= link_to "Sign in", new_user_session_path %>
    <%= link_to "Sign up", new_user_registration_path %>
  <% end %>

  <%# ログインユーザーの情報 %>
  <% if current_user %>
    <p>Role: <%= current_user.role %></p>
    <p>Sign in count: <%= current_user.sign_in_count %></p>
    <p>Last sign in: <%= current_user.last_sign_in_at %></p>
  <% end %>
ERB

puts view_helpers
puts ""

puts "7. Deviseの設定ファイル"
puts "-" * 40
puts ""

devise_config = <<~RUBY
  # config/initializers/devise.rb
  Devise.setup do |config|
    # メーラーの送信元
    config.mailer_sender = 'noreply@example.com'

    # ORMの指定
    require 'devise/orm/active_record'

    # 認証キー（デフォルトはemail）
    config.authentication_keys = [:email]

    # 大文字小文字を区別しない
    config.case_insensitive_keys = [:email]

    # 空白を削除
    config.strip_whitespace_keys = [:email]

    # パスワードの最小長
    config.password_length = 8..128

    # メール確認の有効期限
    config.confirm_within = 3.days

    # パスワードリセットの有効期限
    config.reset_password_within = 6.hours

    # ログアウト時の動作
    config.sign_out_via = :delete

    # セッションタイムアウト
    config.timeout_in = 30.minutes

    # アカウントロック
    config.lock_strategy = :failed_attempts
    config.unlock_strategy = :both
    config.maximum_attempts = 5
    config.unlock_in = 1.hour

    # Remember me
    config.remember_for = 2.weeks
  end
RUBY

puts devise_config
puts ""

puts "8. ビューのカスタマイズ"
puts "-" * 40
puts ""

puts "■ ビューファイルの生成:"
puts ""

view_generate = <<~BASH
  # すべてのビューを生成
  rails generate devise:views

  # 特定のビューのみ生成
  rails generate devise:views -v sessions registrations passwords

  # スコープを指定して生成
  rails generate devise:views users
BASH

puts view_generate
puts ""

puts "■ 生成されるファイル:"
puts ""

view_files = <<~TEXT
  app/views/devise/
  ├── confirmations/
  │   └── new.html.erb        # 確認メール再送信
  ├── mailer/
  │   ├── confirmation_instructions.html.erb
  │   ├── email_changed.html.erb
  │   ├── password_change.html.erb
  │   ├── reset_password_instructions.html.erb
  │   └── unlock_instructions.html.erb
  ├── passwords/
  │   ├── edit.html.erb       # パスワード変更
  │   └── new.html.erb        # パスワードリセット要求
  ├── registrations/
  │   ├── edit.html.erb       # アカウント編集
  │   └── new.html.erb        # ユーザー登録
  ├── sessions/
  │   └── new.html.erb        # ログイン
  ├── shared/
  │   ├── _error_messages.html.erb
  │   └── _links.html.erb
  └── unlocks/
      └── new.html.erb        # アカウントロック解除
TEXT

puts view_files
puts ""

puts "9. コントローラのカスタマイズ"
puts "-" * 40
puts ""

puts "■ コントローラの生成:"
puts ""

controller_generate = <<~BASH
  rails generate devise:controllers users
BASH

puts controller_generate
puts ""

puts "■ ルーティングの設定:"
puts ""

routes_config = <<~RUBY
  # config/routes.rb
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations',
    passwords: 'users/passwords',
    confirmations: 'users/confirmations'
  }
RUBY

puts routes_config
puts ""

puts "■ カスタムコントローラの例:"
puts ""

custom_controller = <<~RUBY
  # app/controllers/users/registrations_controller.rb
  class Users::RegistrationsController < Devise::RegistrationsController
    before_action :configure_sign_up_params, only: [:create]
    before_action :configure_account_update_params, only: [:update]

    protected

    # 登録時に許可するパラメータ
    def configure_sign_up_params
      devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :age, :avatar])
    end

    # 更新時に許可するパラメータ
    def configure_account_update_params
      devise_parameter_sanitizer.permit(:account_update, keys: [:name, :age, :avatar])
    end

    # 登録後のリダイレクト先
    def after_sign_up_path_for(resource)
      edit_user_registration_path
    end

    # 更新後のリダイレクト先
    def after_update_path_for(resource)
      user_path(resource)
    end
  end
RUBY

puts custom_controller
puts ""

puts "=" * 80
puts "ベストプラクティス"
puts "=" * 80
puts ""

puts "1. セキュリティ:"
puts "   - 強力なパスワードポリシーを設定"
puts "   - アカウントロック機能を有効化"
puts "   - セッションタイムアウトを適切に設定"
puts ""

puts "2. ユーザーエクスペリエンス:"
puts "   - 分かりやすいエラーメッセージ"
puts "   - パスワードリセットの簡単な手順"
puts "   - Remember me機能の提供"
puts ""

puts "3. メール設定:"
puts "   - 本番環境でのメール送信設定"
puts "   - メールテンプレートのカスタマイズ"
puts "   - 確認メールの有効期限設定"
puts ""

puts "=" * 80
