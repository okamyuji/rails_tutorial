# frozen_string_literal: true

# Users::RegistrationsController
# ユーザー登録・アカウント編集をカスタマイズします

module Users
  class RegistrationsController < Devise::RegistrationsController
    before_action :configure_sign_up_params, only: [:create]
    before_action :configure_account_update_params, only: [:update]

    # GET /users/sign_up
    # 登録フォームを表示
    def new
      super
    end

    # POST /users
    # ユーザー登録処理
    def create
      super do |resource|
        if resource.persisted?
          # 登録成功時の追加処理
          
          # ウェルカムメールを送信（オプション）
          # UserMailer.welcome_email(resource).deliver_later
          
          # 登録ログを記録
          Rails.logger.info "New user registered: #{resource.email}"
        end
      end
    end

    # GET /users/edit
    # アカウント編集フォームを表示
    def edit
      super
    end

    # PUT /users
    # アカウント更新処理
    def update
      super do |resource|
        if resource.errors.empty?
          # 更新成功時の追加処理
          Rails.logger.info "User updated: #{resource.email}"
        end
      end
    end

    # DELETE /users
    # アカウント削除処理
    def destroy
      super do |resource|
        # 削除成功時の追加処理
        Rails.logger.info "User deleted: #{resource.email}"
        
        # 関連データのクリーンアップ（オプション）
        # cleanup_user_data(resource)
      end
    end

    # GET /users/cancel
    # 登録キャンセル
    def cancel
      super
    end

    protected

    # 登録時に許可するパラメータ
    def configure_sign_up_params
      devise_parameter_sanitizer.permit(:sign_up, keys: [
        :name,
        :avatar
      ])
    end

    # アカウント更新時に許可するパラメータ
    def configure_account_update_params
      devise_parameter_sanitizer.permit(:account_update, keys: [
        :name,
        :avatar
      ])
    end

    # 登録後のリダイレクト先
    def after_sign_up_path_for(resource)
      # メール確認が必要な場合
      if resource.respond_to?(:confirmed?) && !resource.confirmed?
        flash[:notice] = 'A confirmation email has been sent to your email address.'
        root_path
      else
        edit_user_registration_path
      end
    end

    # 確認待ち状態での登録後のリダイレクト先
    def after_inactive_sign_up_path_for(_resource)
      new_user_session_path
    end

    # アカウント更新後のリダイレクト先
    def after_update_path_for(resource)
      if sign_in_after_change_password?
        edit_user_registration_path
      else
        new_user_session_path
      end
    end

    # パスワードなしでアカウント更新を許可するかどうか
    def update_resource(resource, params)
      # パスワードが空の場合はパスワードなしで更新
      if params[:password].blank? && params[:password_confirmation].blank?
        params.delete(:password)
        params.delete(:password_confirmation)
        params.delete(:current_password)
        resource.update_without_password(params)
      else
        super
      end
    end

    private

    # ユーザーデータのクリーンアップ
    def cleanup_user_data(user)
      # 関連データの削除やアーカイブ処理
      # user.articles.destroy_all
      # user.comments.destroy_all
    end
  end
end

