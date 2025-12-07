# frozen_string_literal: true

# Users::OmniauthCallbacksController
# OmniAuthのコールバックを処理します

module Users
  class OmniauthCallbacksController < Devise::OmniauthCallbacksController
    # Google OAuth2のコールバック
    def google_oauth2
      handle_auth('Google')
    end

    # Facebookのコールバック
    def facebook
      handle_auth('Facebook')
    end

    # GitHubのコールバック
    def github
      handle_auth('GitHub')
    end

    # 認証失敗時
    def failure
      flash[:alert] = failure_message
      redirect_to root_path
    end

    private

    # 認証処理の共通メソッド
    #
    # @param provider [String] プロバイダ名
    def handle_auth(provider)
      auth = request.env['omniauth.auth']
      @user = User.from_omniauth(auth)

      if @user.persisted?
        # 認証成功
        sign_in_and_redirect @user, event: :authentication
        set_flash_message(:notice, :success, kind: provider) if is_navigational_format?
        
        # ログを記録
        Rails.logger.info "User signed in via #{provider}: #{@user.email}"
      else
        # ユーザー作成に失敗
        session['devise.oauth_data'] = auth.except(:extra)
        redirect_to new_user_registration_url, alert: @user.errors.full_messages.join("\n")
      end
    end

    # 失敗メッセージを生成
    #
    # @return [String]
    def failure_message
      exception = request.env['omniauth.error']
      error_type = request.env['omniauth.error.type']
      strategy = request.env['omniauth.error.strategy']

      message = if exception
                  "Authentication failed: #{exception.message}"
                elsif error_type
                  "Authentication failed: #{error_type.to_s.humanize}"
                else
                  'Authentication failed for unknown reason.'
                end

      # ログを記録
      Rails.logger.warn "OAuth failure: #{message} (strategy: #{strategy&.name})"

      message
    end

    # 認証後のリダイレクト先
    def after_omniauth_failure_path_for(_scope)
      new_user_session_path
    end

    # 認証成功後のリダイレクト先
    def after_sign_in_path_for(resource)
      stored_location_for(resource) || root_path
    end
  end
end

