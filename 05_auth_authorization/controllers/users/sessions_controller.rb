# frozen_string_literal: true

# Users::SessionsController
# ログイン・ログアウトをカスタマイズします

module Users
  class SessionsController < Devise::SessionsController
    # ログイン前のフィルター
    # before_action :configure_sign_in_params, only: [:create]

    # GET /users/sign_in
    # ログインフォームを表示
    def new
      super
    end

    # POST /users/sign_in
    # ログイン処理
    def create
      super do |resource|
        # ログイン成功時の追加処理
        if resource.persisted?
          # セッションIDを再生成（セッション固定攻撃対策）
          # Deviseは自動的に行うが、明示的に記述
          
          # ログイン履歴を記録（オプション）
          log_sign_in(resource) if respond_to?(:log_sign_in, true)
        end
      end
    end

    # DELETE /users/sign_out
    # ログアウト処理
    def destroy
      # ログアウト前の処理
      user = current_user
      
      super do
        # ログアウト成功時の追加処理
        # ログアウト履歴を記録（オプション）
        log_sign_out(user) if respond_to?(:log_sign_out, true) && user
      end
    end

    protected

    # ログイン後のリダイレクト先
    def after_sign_in_path_for(resource)
      stored_location_for(resource) || root_path
    end

    # ログアウト後のリダイレクト先
    def after_sign_out_path_for(_resource_or_scope)
      new_user_session_path
    end

    # ログイン失敗時のメッセージをカスタマイズ
    def auth_options
      { scope: resource_name, recall: "#{controller_path}#new" }
    end

    private

    # ログイン履歴を記録
    def log_sign_in(user)
      Rails.logger.info "User signed in: #{user.email} from #{request.remote_ip}"
      
      # LoginHistoryモデルがある場合
      # LoginHistory.create!(
      #   user: user,
      #   ip_address: request.remote_ip,
      #   user_agent: request.user_agent,
      #   action: 'sign_in'
      # )
    end

    # ログアウト履歴を記録
    def log_sign_out(user)
      Rails.logger.info "User signed out: #{user.email} from #{request.remote_ip}"
    end

    # ログインパラメータの設定（必要に応じて）
    # def configure_sign_in_params
    #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
    # end
  end
end

