# frozen_string_literal: true

# OmniAuthによる外部認証のデモンストレーション
# rails runner omniauth_demo.rb で実行します

puts "=" * 80
puts "OmniAuthによる外部認証のデモンストレーション"
puts "=" * 80
puts ""

puts "1. OmniAuthの概要"
puts "-" * 40
puts ""

overview = <<~TEXT
  OmniAuthは、外部認証プロバイダとの連携を簡単に実装できるgemです。

  対応プロバイダ:
  - Google
  - Facebook
  - Twitter
  - GitHub
  - Apple
  - Microsoft
  - LinkedIn
  - その他多数

  メリット:
  - ユーザーはパスワードを覚える必要がない
  - 登録プロセスが簡略化される
  - 信頼性の高い認証プロバイダを利用
TEXT

puts overview
puts ""

puts "2. インストール"
puts "-" * 40
puts ""

gemfile = <<~RUBY
  # Gemfile

  # Google認証
  gem 'omniauth-google-oauth2'

  # Facebook認証
  gem 'omniauth-facebook'

  # GitHub認証
  gem 'omniauth-github'

  # CSRF対策（必須）
  gem 'omniauth-rails_csrf_protection'
RUBY

puts gemfile
puts ""

puts "3. Deviseとの統合"
puts "-" * 40
puts ""

puts "■ Devise設定ファイル:"
puts ""

devise_config = <<~RUBY
  # config/initializers/devise.rb
  Devise.setup do |config|
    # Google OAuth2
    config.omniauth :google_oauth2,
                    ENV['GOOGLE_CLIENT_ID'],
                    ENV['GOOGLE_CLIENT_SECRET'],
                    scope: 'email,profile',
                    prompt: 'select_account'

    # Facebook
    config.omniauth :facebook,
                    ENV['FACEBOOK_APP_ID'],
                    ENV['FACEBOOK_APP_SECRET'],
                    scope: 'email,public_profile',
                    info_fields: 'email,name,first_name,last_name'

    # GitHub
    config.omniauth :github,
                    ENV['GITHUB_CLIENT_ID'],
                    ENV['GITHUB_CLIENT_SECRET'],
                    scope: 'user:email'
  end
RUBY

puts devise_config
puts ""

puts "■ Userモデルの設定:"
puts ""

user_model = <<~RUBY
  # app/models/user.rb
  class User < ApplicationRecord
    devise :database_authenticatable, :registerable,
           :recoverable, :rememberable, :validatable,
           :omniauthable, omniauth_providers: [:google_oauth2, :facebook, :github]

    # OmniAuthからユーザーを作成または取得
    def self.from_omniauth(auth)
      where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
        user.email = auth.info.email
        user.password = Devise.friendly_token[0, 20]
        user.name = auth.info.name
        user.avatar_url = auth.info.image

        # メール確認をスキップ（外部プロバイダで確認済みのため）
        user.skip_confirmation! if user.respond_to?(:skip_confirmation!)
      end
    end

    # 既存のアカウントとOAuth認証を連携
    def self.from_omniauth_connect(auth, current_user)
      # 既存のOAuthアカウントを検索
      identity = where(provider: auth.provider, uid: auth.uid).first

      if identity
        # 既存のOAuthアカウントがある場合
        identity
      elsif current_user
        # ログイン中のユーザーに連携
        current_user.update(
          provider: auth.provider,
          uid: auth.uid
        )
        current_user
      else
        # 新規作成
        from_omniauth(auth)
      end
    end
  end
RUBY

puts user_model
puts ""

puts "4. コールバックコントローラ"
puts "-" * 40
puts ""

callback_controller = <<~RUBY
  # app/controllers/users/omniauth_callbacks_controller.rb
  class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
    # Google認証のコールバック
    def google_oauth2
      handle_auth('Google')
    end

    # Facebook認証のコールバック
    def facebook
      handle_auth('Facebook')
    end

    # GitHub認証のコールバック
    def github
      handle_auth('GitHub')
    end

    # 認証失敗時
    def failure
      redirect_to root_path, alert: "Authentication failed: \#{failure_message}"
    end

    private

    def handle_auth(provider)
      @user = User.from_omniauth(request.env['omniauth.auth'])

      if @user.persisted?
        # 認証成功
        sign_in_and_redirect @user, event: :authentication
        set_flash_message(:notice, :success, kind: provider) if is_navigational_format?
      else
        # 認証失敗（ユーザー作成に失敗）
        session['devise.oauth_data'] = request.env['omniauth.auth'].except(:extra)
        redirect_to new_user_registration_url, alert: @user.errors.full_messages.join("\\n")
      end
    end

    def failure_message
      exception = request.env['omniauth.error']
      error = request.env['omniauth.error.type']
  #{"    "}
      if exception
        exception.message
      elsif error
        error.to_s.humanize
      else
        'Unknown error'
      end
    end
  end
RUBY

puts callback_controller
puts ""

puts "5. ルーティング"
puts "-" * 40
puts ""

routes = <<~RUBY
  # config/routes.rb
  Rails.application.routes.draw do
    devise_for :users, controllers: {
      omniauth_callbacks: 'users/omniauth_callbacks',
      registrations: 'users/registrations',
      sessions: 'users/sessions'
    }
  end
RUBY

puts routes
puts ""

puts "6. ビューでのログインボタン"
puts "-" * 40
puts ""

view_buttons = <<~ERB
  <%# app/views/devise/sessions/new.html.erb %>
  <h2>Log in</h2>

  <%# 通常のログインフォーム %>
  <%= form_for(resource, as: resource_name, url: session_path(resource_name)) do |f| %>
    <div class="field">
      <%= f.label :email %>
      <%= f.email_field :email, autofocus: true, autocomplete: "email" %>
    </div>

    <div class="field">
      <%= f.label :password %>
      <%= f.password_field :password, autocomplete: "current-password" %>
    </div>

    <div class="field">
      <%= f.check_box :remember_me %>
      <%= f.label :remember_me %>
    </div>

    <div class="actions">
      <%= f.submit "Log in" %>
    </div>
  <% end %>

  <%# ソーシャルログインボタン %>
  <div class="social-login">
    <p>Or sign in with:</p>
  #{"  "}
    <%# Google %>
    <%= button_to user_google_oauth2_omniauth_authorize_path,#{" "}
                  method: :post,#{" "}
                  data: { turbo: false },
                  class: "btn btn-google" do %>
      <svg class="icon"><!-- Google icon --></svg>
      Sign in with Google
    <% end %>
  #{"  "}
    <%# Facebook %>
    <%= button_to user_facebook_omniauth_authorize_path,#{" "}
                  method: :post,#{" "}
                  data: { turbo: false },
                  class: "btn btn-facebook" do %>
      <svg class="icon"><!-- Facebook icon --></svg>
      Sign in with Facebook
    <% end %>
  #{"  "}
    <%# GitHub %>
    <%= button_to user_github_omniauth_authorize_path,#{" "}
                  method: :post,#{" "}
                  data: { turbo: false },
                  class: "btn btn-github" do %>
      <svg class="icon"><!-- GitHub icon --></svg>
      Sign in with GitHub
    <% end %>
  </div>

  <%# 重要: data: { turbo: false } でTurboを無効化 %>
  <%# OmniAuthのリダイレクトはTurboと互換性がないため %>
ERB

puts view_buttons
puts ""

puts "7. 環境変数の設定"
puts "-" * 40
puts ""

env_setup = <<~TEXT
  ■ 開発環境（.env ファイル）:

  GOOGLE_CLIENT_ID=your-google-client-id
  GOOGLE_CLIENT_SECRET=your-google-client-secret
  FACEBOOK_APP_ID=your-facebook-app-id
  FACEBOOK_APP_SECRET=your-facebook-app-secret
  GITHUB_CLIENT_ID=your-github-client-id
  GITHUB_CLIENT_SECRET=your-github-client-secret

  ■ 本番環境（Rails credentials）:

  rails credentials:edit

  # credentials.yml.enc
  google:
    client_id: your-google-client-id
    client_secret: your-google-client-secret
  facebook:
    app_id: your-facebook-app-id
    app_secret: your-facebook-app-secret
  github:
    client_id: your-github-client-id
    client_secret: your-github-client-secret

  ■ Devise設定での参照:

  config.omniauth :google_oauth2,
                  Rails.application.credentials.dig(:google, :client_id),
                  Rails.application.credentials.dig(:google, :client_secret)
TEXT

puts env_setup
puts ""

puts "8. OAuthプロバイダの設定"
puts "-" * 40
puts ""

provider_setup = <<~TEXT
  ■ Google Cloud Console:
    1. https://console.cloud.google.com/ にアクセス
    2. 新しいプロジェクトを作成
    3. APIとサービス > 認証情報 > OAuth 2.0 クライアントID作成
    4. 承認済みのリダイレクトURI:
       - 開発: http://localhost:3000/users/auth/google_oauth2/callback
       - 本番: https://yourdomain.com/users/auth/google_oauth2/callback

  ■ Facebook Developers:
    1. https://developers.facebook.com/ にアクセス
    2. 新しいアプリを作成
    3. Facebookログインを追加
    4. 有効なOAuthリダイレクトURI:
       - 開発: http://localhost:3000/users/auth/facebook/callback
       - 本番: https://yourdomain.com/users/auth/facebook/callback

  ■ GitHub:
    1. https://github.com/settings/developers にアクセス
    2. 新しいOAuth Appを作成
    3. Authorization callback URL:
       - 開発: http://localhost:3000/users/auth/github/callback
       - 本番: https://yourdomain.com/users/auth/github/callback
TEXT

puts provider_setup
puts ""

puts "9. マイグレーション"
puts "-" * 40
puts ""

migration = <<~RUBY
  # db/migrate/XXXXXX_add_omniauth_to_users.rb
  class AddOmniauthToUsers < ActiveRecord::Migration[7.2]
    def change
      add_column :users, :provider, :string
      add_column :users, :uid, :string
      add_column :users, :avatar_url, :string

      add_index :users, [:provider, :uid], unique: true
    end
  end
RUBY

puts migration
puts ""

puts "=" * 80
puts "セキュリティ上の注意点"
puts "=" * 80
puts ""

puts "1. CSRF対策:"
puts "   - omniauth-rails_csrf_protection gemを必ず使用"
puts "   - POSTメソッドでOAuth認証を開始"
puts ""

puts "2. 秘密情報の管理:"
puts "   - クライアントシークレットをコードにハードコーディングしない"
puts "   - 環境変数またはcredentialsを使用"
puts ""

puts "3. スコープの最小化:"
puts "   - 必要最小限の情報のみを要求"
puts "   - ユーザーのプライバシーを尊重"
puts ""

puts "4. コールバックURLの検証:"
puts "   - 本番環境では正確なドメインを設定"
puts "   - HTTPSを使用"
puts ""

puts "=" * 80
