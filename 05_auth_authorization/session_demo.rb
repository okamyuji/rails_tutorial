# frozen_string_literal: true

# セッションとCookie管理のデモンストレーション
# rails runner session_demo.rb で実行します

puts "=" * 80
puts "セッションとCookie管理のデモンストレーション"
puts "=" * 80
puts ""

puts "1. セッションの概要"
puts "-" * 40
puts ""

overview = <<~TEXT
  セッションは、ユーザーの状態をリクエスト間で保持する仕組みです。

  Railsのセッションストア:
  - CookieStore（デフォルト）: セッションデータをCookieに保存
  - CacheStore: キャッシュストアに保存
  - ActiveRecordStore: データベースに保存
  - RedisStore: Redisに保存

  CookieStoreの特徴:
  - サーバー側にストレージ不要
  - 4KBのサイズ制限
  - 暗号化されて保存
TEXT

puts overview
puts ""

puts "2. セッションストアの設定"
puts "-" * 40
puts ""

session_store_config = <<~RUBY
  # config/initializers/session_store.rb

  # CookieStore（デフォルト）
  Rails.application.config.session_store :cookie_store,
    key: '_myapp_session',
    secure: Rails.env.production?,  # HTTPSでのみCookieを送信
    httponly: true,                 # JavaScriptからのアクセスを防止
    same_site: :lax                 # クロスサイトリクエストでのCookie送信を制限

  # RedisStore（大規模アプリケーション向け）
  # Gemfile: gem 'redis-rails'
  Rails.application.config.session_store :redis_store,
    servers: [ENV['REDIS_URL'] || 'redis://localhost:6379/0/session'],
    expire_after: 1.week,
    key: '_myapp_session',
    secure: Rails.env.production?,
    httponly: true,
    same_site: :lax

  # ActiveRecordStore（データベースに保存）
  # rails generate active_record:session_migration
  Rails.application.config.session_store :active_record_store,
    key: '_myapp_session',
    secure: Rails.env.production?,
    httponly: true,
    same_site: :lax
RUBY

puts session_store_config
puts ""

puts "3. セッションの操作"
puts "-" * 40
puts ""

session_operations = <<~RUBY
  # app/controllers/application_controller.rb
  class ApplicationController < ActionController::Base
    # セッションに値を保存
    def set_user_preference
      session[:theme] = 'dark'
      session[:language] = 'ja'
      session[:sidebar_collapsed] = true
    end

    # セッションから値を取得
    def get_user_preference
      theme = session[:theme] || 'light'
      language = session[:language] || 'en'
      sidebar_collapsed = session[:sidebar_collapsed] || false
    end

    # セッションから値を削除
    def clear_user_preference
      session.delete(:theme)
      session.delete(:language)
    end

    # セッション全体をクリア
    def clear_session
      reset_session
    end

    # セッションIDの再生成（セキュリティ対策）
    def regenerate_session
      # ログイン時にセッションIDを再生成してセッション固定攻撃を防ぐ
      reset_session
      session[:user_id] = @user.id
    end
  end
RUBY

puts session_operations
puts ""

puts "4. Cookieの操作"
puts "-" * 40
puts ""

cookie_operations = <<~RUBY
  # app/controllers/application_controller.rb
  class ApplicationController < ActionController::Base
    # 通常のCookie
    def set_cookie
      cookies[:user_preference] = {
        value: 'dark_mode',
        expires: 1.year.from_now,
        secure: Rails.env.production?,
        httponly: false  # JavaScriptからアクセス可能
      }
    end

    # 永続Cookie（20年間有効）
    def set_permanent_cookie
      cookies.permanent[:remember_token] = 'abc123'
    end

    # 署名付きCookie（改ざん検出可能）
    def set_signed_cookie
      cookies.signed[:user_id] = current_user.id
  #{"    "}
      # 読み取り
      user_id = cookies.signed[:user_id]
    end

    # 暗号化Cookie（内容を隠蔽）
    def set_encrypted_cookie
      cookies.encrypted[:sensitive_data] = {
        value: { user_id: current_user.id, role: current_user.role }.to_json,
        expires: 1.week.from_now
      }
  #{"    "}
      # 読み取り
      data = JSON.parse(cookies.encrypted[:sensitive_data])
    end

    # Cookieの削除
    def delete_cookie
      cookies.delete(:user_preference)
      cookies.delete(:remember_token, domain: '.example.com')
    end
  end
RUBY

puts cookie_operations
puts ""

puts "5. Remember Me機能の実装"
puts "-" * 40
puts ""

remember_me = <<~RUBY
  # app/models/user.rb
  class User < ApplicationRecord
    attr_accessor :remember_token

    # 永続セッション用のトークンを生成
    def remember
      self.remember_token = SecureRandom.urlsafe_base64
      update_attribute(:remember_digest, BCrypt::Password.create(remember_token))
    end

    # 永続セッションを破棄
    def forget
      update_attribute(:remember_digest, nil)
    end

    # トークンが一致するか確認
    def authenticated?(remember_token)
      return false if remember_digest.nil?
      BCrypt::Password.new(remember_digest).is_password?(remember_token)
    end
  end

  # app/controllers/sessions_controller.rb
  class SessionsController < ApplicationController
    def create
      user = User.find_by(email: params[:session][:email].downcase)
  #{"    "}
      if user&.authenticate(params[:session][:password])
        log_in(user)
  #{"      "}
        # Remember Me
        if params[:session][:remember_me] == '1'
          remember(user)
        else
          forget(user)
        end
  #{"      "}
        redirect_to user
      else
        flash.now[:danger] = 'Invalid email/password combination'
        render 'new'
      end
    end

    def destroy
      log_out if logged_in?
      redirect_to root_url
    end
  end

  # app/helpers/sessions_helper.rb
  module SessionsHelper
    def log_in(user)
      session[:user_id] = user.id
    end

    def remember(user)
      user.remember
      cookies.permanent.encrypted[:user_id] = user.id
      cookies.permanent[:remember_token] = user.remember_token
    end

    def forget(user)
      user.forget
      cookies.delete(:user_id)
      cookies.delete(:remember_token)
    end

    def current_user
      if (user_id = session[:user_id])
        @current_user ||= User.find_by(id: user_id)
      elsif (user_id = cookies.encrypted[:user_id])
        user = User.find_by(id: user_id)
        if user&.authenticated?(cookies[:remember_token])
          log_in(user)
          @current_user = user
        end
      end
    end

    def logged_in?
      !current_user.nil?
    end

    def log_out
      forget(current_user)
      reset_session
      @current_user = nil
    end
  end
RUBY

puts remember_me
puts ""

puts "6. セキュリティ設定"
puts "-" * 40
puts ""

security_config = <<~RUBY
  # config/application.rb
  module MyApp
    class Application < Rails::Application
      # セッションの設定
      config.session_store :cookie_store,
        key: '_myapp_session',
        secure: Rails.env.production?,
        httponly: true,
        same_site: :lax

      # Cookieの暗号化キー
      config.action_dispatch.signed_cookie_salt = 'signed cookie'
      config.action_dispatch.encrypted_cookie_salt = 'encrypted cookie'
      config.action_dispatch.encrypted_signed_cookie_salt = 'signed encrypted cookie'
    end
  end

  # config/environments/production.rb
  Rails.application.configure do
    # HTTPSを強制
    config.force_ssl = true

    # セキュアCookieを使用
    config.session_store :cookie_store,
      key: '_myapp_session',
      secure: true,
      httponly: true,
      same_site: :strict
  end
RUBY

puts security_config
puts ""

puts "7. CSRF対策"
puts "-" * 40
puts ""

csrf_protection = <<~RUBY
  # app/controllers/application_controller.rb
  class ApplicationController < ActionController::Base
    # CSRFトークンの検証を有効化（デフォルトで有効）
    protect_from_forgery with: :exception

    # APIコントローラではCSRF保護を無効化する場合
    # protect_from_forgery with: :null_session
  end

  # app/views/layouts/application.html.erb
  # CSRFメタタグを含める
  <%= csrf_meta_tags %>

  # フォームでは自動的にCSRFトークンが含まれる
  <%= form_with model: @article do |f| %>
    <%# authenticity_tokenが自動的に追加される %>
  <% end %>

  # JavaScriptからのリクエスト
  # CSRFトークンをヘッダーに含める
  const token = document.querySelector('meta[name="csrf-token"]').content;
  fetch('/articles', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'X-CSRF-Token': token
    },
    body: JSON.stringify({ title: 'New Article' })
  });
RUBY

puts csrf_protection
puts ""

puts "8. セッションタイムアウト"
puts "-" * 40
puts ""

session_timeout = <<~RUBY
  # Deviseを使用している場合
  # config/initializers/devise.rb
  Devise.setup do |config|
    # 30分間操作がないとタイムアウト
    config.timeout_in = 30.minutes
  end

  # カスタム実装
  # app/controllers/application_controller.rb
  class ApplicationController < ActionController::Base
    before_action :check_session_timeout

    private

    def check_session_timeout
      return unless current_user

      if session[:last_activity_at]
        if session[:last_activity_at] < 30.minutes.ago
          reset_session
          redirect_to login_path, alert: 'Your session has expired. Please log in again.'
          return
        end
      end

      session[:last_activity_at] = Time.current
    end
  end
RUBY

puts session_timeout
puts ""

puts "=" * 80
puts "セキュリティのベストプラクティス"
puts "=" * 80
puts ""

puts "1. Cookie設定:"
puts "   - secure: true（本番環境でHTTPS必須）"
puts "   - httponly: true（XSS対策）"
puts "   - same_site: :lax または :strict（CSRF対策）"
puts ""

puts "2. セッション管理:"
puts "   - ログイン時にセッションIDを再生成"
puts "   - 適切なタイムアウト設定"
puts "   - ログアウト時にセッションを完全にクリア"
puts ""

puts "3. 機密情報:"
puts "   - 暗号化Cookieを使用"
puts "   - センシティブなデータはセッションに保存しない"
puts "   - パスワードは絶対にセッションに保存しない"
puts ""

puts "4. CSRF対策:"
puts "   - protect_from_forgeryを有効化"
puts "   - CSRFトークンをフォームに含める"
puts "   - same_site Cookie属性を設定"
puts ""

puts "=" * 80
