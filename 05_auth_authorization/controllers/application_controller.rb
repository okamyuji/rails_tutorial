# frozen_string_literal: true

# ApplicationController
# すべてのコントローラの基底クラスです
# 認証と認可の基盤を提供します

class ApplicationController < ActionController::Base
  # Punditを組み込み
  include Pundit::Authorization

  # CSRF対策
  protect_from_forgery with: :exception

  # Punditの権限エラーをハンドリング
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  # レコードが見つからない場合のエラーハンドリング
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  # 認証が必要な場合のリダイレクト先
  before_action :configure_permitted_parameters, if: :devise_controller?

  # すべてのアクションで権限チェックを強制（オプション）
  # after_action :verify_authorized, except: :index
  # after_action :verify_policy_scoped, only: :index

  private

  # 権限エラー時の処理
  #
  # @param exception [Pundit::NotAuthorizedError] 例外オブジェクト
  def user_not_authorized(exception)
    policy_name = exception.policy.class.to_s.underscore

    flash[:alert] = t(
      "pundit.#{policy_name}.#{exception.query}",
      default: "You are not authorized to perform this action."
    )

    redirect_back(fallback_location: root_path)
  end

  # レコードが見つからない場合の処理
  def record_not_found
    flash[:alert] = "The requested resource was not found."
    redirect_back(fallback_location: root_path)
  end

  # Deviseのパラメータ設定
  def configure_permitted_parameters
    # サインアップ時に許可するパラメータ
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[name avatar])

    # アカウント更新時に許可するパラメータ
    devise_parameter_sanitizer.permit(:account_update, keys: %i[name avatar])
  end

  # 現在のユーザーを取得（Deviseのヘルパー）
  # Punditで使用されます
  def pundit_user
    current_user
  end

  # 認証後のリダイレクト先
  def after_sign_in_path_for(resource)
    stored_location_for(resource) || root_path
  end

  # ログアウト後のリダイレクト先
  def after_sign_out_path_for(_resource_or_scope)
    root_path
  end

  # 管理者のみアクセス可能
  def require_admin!
    unless current_user&.admin?
      flash[:alert] = "Admin access required."
      redirect_to root_path
    end
  end

  # 編集者以上のみアクセス可能
  def require_editor_or_above!
    unless current_user&.editor? || current_user&.admin?
      flash[:alert] = "Editor access required."
      redirect_to root_path
    end
  end
end
