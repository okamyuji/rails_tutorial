# frozen_string_literal: true

# Deviseの設定ファイル
# config/initializers/devise.rb

Devise.setup do |config|
  # ==> メーラー設定
  # メール送信元アドレス
  config.mailer_sender = 'noreply@example.com'

  # メーラークラス
  # config.mailer = 'Devise::Mailer'

  # 親メーラークラス
  # config.parent_mailer = 'ActionMailer::Base'

  # ==> ORM設定
  require 'devise/orm/active_record'

  # ==> 認証キー設定
  # 認証に使用するキー（デフォルトはemail）
  config.authentication_keys = [:email]

  # リクエストオブジェクトから認証キーを取得する場合
  # config.request_keys = []

  # 大文字小文字を区別しない
  config.case_insensitive_keys = [:email]

  # 空白を削除
  config.strip_whitespace_keys = [:email]

  # パラメータからの認証キー
  # config.params_authenticatable = true

  # HTTPベーシック認証
  # config.http_authenticatable = false

  # HTTP認証のレルム
  # config.http_authenticatable_on_xhr = true

  # 401レスポンスのWWW-Authenticateヘッダー
  # config.http_authentication_realm = 'Application'

  # ==> Database Authenticatable設定
  # パスワードのストレッチ回数（bcrypt）
  config.stretches = Rails.env.test? ? 1 : 12

  # ペッパー（追加のセキュリティ）
  # config.pepper = 'your-pepper-string'

  # 暗号化キーの送信
  # config.send_email_changed_notification = false
  # config.send_password_change_notification = false

  # ==> Confirmable設定
  # 確認トークンの有効期間
  config.confirm_within = 3.days

  # 確認前のアクセス許可
  config.allow_unconfirmed_access_for = 2.days

  # 再確認が必要なキー
  config.reconfirmable = true

  # ==> Rememberable設定
  # Remember meの有効期間
  config.remember_for = 2.weeks

  # Remember meの有効期限を延長
  config.extend_remember_period = false

  # すべてのスコープでRemember meを使用
  # config.rememberable_options = {}

  # ==> Validatable設定
  # パスワードの最小長
  config.password_length = 8..128

  # メールアドレスの正規表現
  config.email_regexp = /\A[^@\s]+@[^@\s]+\z/

  # ==> Timeoutable設定
  # セッションタイムアウト
  config.timeout_in = 30.minutes

  # ==> Lockable設定
  # ロック戦略（:failed_attempts, :none）
  config.lock_strategy = :failed_attempts

  # ロック解除戦略（:email, :time, :both, :none）
  config.unlock_strategy = :both

  # ロックまでの最大試行回数
  config.maximum_attempts = 5

  # ロック解除までの時間
  config.unlock_in = 1.hour

  # 最後の試行時間をリセット
  config.last_attempt_warning = true

  # ==> Recoverable設定
  # パスワードリセットトークンの有効期間
  config.reset_password_within = 6.hours

  # パスワードリセット後に自動サインイン
  config.sign_in_after_reset_password = true

  # ==> Omniauthable設定
  # OmniAuthプロバイダの設定
  # 環境変数またはcredentialsから取得

  # Google OAuth2
  if ENV['GOOGLE_CLIENT_ID'].present?
    config.omniauth :google_oauth2,
                    ENV['GOOGLE_CLIENT_ID'],
                    ENV['GOOGLE_CLIENT_SECRET'],
                    scope: 'email,profile',
                    prompt: 'select_account',
                    image_aspect_ratio: 'square',
                    image_size: 200
  end

  # Facebook
  if ENV['FACEBOOK_APP_ID'].present?
    config.omniauth :facebook,
                    ENV['FACEBOOK_APP_ID'],
                    ENV['FACEBOOK_APP_SECRET'],
                    scope: 'email,public_profile',
                    info_fields: 'email,name,first_name,last_name',
                    image_size: 'large'
  end

  # GitHub
  if ENV['GITHUB_CLIENT_ID'].present?
    config.omniauth :github,
                    ENV['GITHUB_CLIENT_ID'],
                    ENV['GITHUB_CLIENT_SECRET'],
                    scope: 'user:email'
  end

  # ==> ナビゲーション設定
  # サインアウト時のHTTPメソッド
  config.sign_out_via = :delete

  # ==> その他の設定
  # ユーザーがサインインできるかどうかをチェック
  # config.sign_in_after_change_password = true

  # Turboとの互換性
  config.navigational_formats = ['*/*', :html, :turbo_stream]

  # レスポンダー
  config.responder.error_status = :unprocessable_entity
  config.responder.redirect_status = :see_other
end

