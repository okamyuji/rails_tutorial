# frozen_string_literal: true

# OmniAuthの設定
# config/initializers/omniauth.rb

# OmniAuthのロガー設定
OmniAuth.config.logger = Rails.logger

# 失敗時のエンドポイント
OmniAuth.config.on_failure = proc do |env|
  OmniAuth::FailureEndpoint.new(env).redirect_to_failure
end

# テスト環境でのモック設定
if Rails.env.test?
  OmniAuth.config.test_mode = true

  # テスト用のモックデータ
  OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
    provider: 'google_oauth2',
    uid: '123456789',
    info: {
      email: 'test@example.com',
      name: 'Test User',
      first_name: 'Test',
      last_name: 'User',
      image: 'https://example.com/avatar.jpg'
    },
    credentials: {
      token: 'mock_token',
      refresh_token: 'mock_refresh_token',
      expires_at: 1.week.from_now.to_i,
      expires: true
    }
  )

  OmniAuth.config.mock_auth[:facebook] = OmniAuth::AuthHash.new(
    provider: 'facebook',
    uid: '987654321',
    info: {
      email: 'facebook@example.com',
      name: 'Facebook User',
      image: 'https://example.com/fb_avatar.jpg'
    },
    credentials: {
      token: 'mock_fb_token',
      expires_at: 1.week.from_now.to_i,
      expires: true
    }
  )

  OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new(
    provider: 'github',
    uid: '456789123',
    info: {
      email: 'github@example.com',
      name: 'GitHub User',
      nickname: 'githubuser',
      image: 'https://example.com/gh_avatar.jpg'
    },
    credentials: {
      token: 'mock_gh_token',
      expires: false
    }
  )
end

# プロバイダ設定のヘルパー
# 環境変数から設定を読み込む
module OmniAuthConfig
  class << self
    def google_oauth2_configured?
      ENV['GOOGLE_CLIENT_ID'].present? && ENV['GOOGLE_CLIENT_SECRET'].present?
    end

    def facebook_configured?
      ENV['FACEBOOK_APP_ID'].present? && ENV['FACEBOOK_APP_SECRET'].present?
    end

    def github_configured?
      ENV['GITHUB_CLIENT_ID'].present? && ENV['GITHUB_CLIENT_SECRET'].present?
    end

    def any_provider_configured?
      google_oauth2_configured? || facebook_configured? || github_configured?
    end

    def configured_providers
      providers = []
      providers << :google_oauth2 if google_oauth2_configured?
      providers << :facebook if facebook_configured?
      providers << :github if github_configured?
      providers
    end
  end
end

# OAuthプロバイダの設定手順:
#
# Google OAuth2:
#   1. https://console.cloud.google.com/ にアクセス
#   2. プロジェクトを作成
#   3. APIとサービス > 認証情報 > OAuth 2.0 クライアントID作成
#   4. 承認済みのリダイレクトURIを設定:
#      - 開発: http://localhost:3000/users/auth/google_oauth2/callback
#      - 本番: https://yourdomain.com/users/auth/google_oauth2/callback
#   5. クライアントIDとシークレットを環境変数に設定
#
# Facebook:
#   1. https://developers.facebook.com/ にアクセス
#   2. アプリを作成
#   3. Facebookログインを追加
#   4. 有効なOAuthリダイレクトURIを設定
#   5. アプリIDとシークレットを環境変数に設定
#
# GitHub:
#   1. https://github.com/settings/developers にアクセス
#   2. New OAuth Appを作成
#   3. Authorization callback URLを設定
#   4. クライアントIDとシークレットを環境変数に設定

