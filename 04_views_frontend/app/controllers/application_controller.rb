class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  stale_when_importmap_changes

  private

  # 認証が未実装のため、仮のcurrent_userを返す
  def current_user
    @current_user ||= User.first
  end
  helper_method :current_user
end
