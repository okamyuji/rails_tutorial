# frozen_string_literal: true

# Sentry設定
# config/initializers/sentry.rb

Sentry.init do |config|
  # DSN（必須）
  config.dsn = ENV.fetch("SENTRY_DSN", nil)

  # 環境名
  config.environment = Rails.env

  # リリースバージョン
  config.release =
    begin
      ENV["GIT_COMMIT"] || `git rev-parse HEAD`.strip
    rescue StandardError
      "unknown"
    end

  # パンくずリスト（イベントまでの経緯を記録）
  config.breadcrumbs_logger = %i[active_support_logger http_logger]

  # トレースサンプリング率
  # 本番環境では低めに設定（コスト削減）
  config.traces_sample_rate = Rails.env.production? ? 0.1 : 1.0

  # プロファイリング（オプション）
  # config.profiles_sample_rate = 0.1

  # 送信するデータの制御
  config.send_default_pii = false # 個人情報を送信しない

  # 除外するエラー
  config.excluded_exceptions += %w[
    ActionController::RoutingError
    ActionController::InvalidAuthenticityToken
    ActiveRecord::RecordNotFound
    ActionController::UnknownFormat
  ]

  # 機密情報のフィルタリング
  config.before_send =
    lambda do |event, _hint|
      # パスワードなどをフィルタリング
      if event.request&.data
        event.request.data = filter_sensitive_data(event.request.data)
      end
      event
    end

  # コンテキストの追加
  config.before_send =
    lambda do |event, _hint|
      # ユーザー情報を追加（ログイン中の場合）
      if defined?(current_user) && current_user
        event.user = {
          id: current_user.id,
          email: current_user.email,
          username: current_user.name
        }
      end
      event
    end

  # 非同期送信
  config.background_worker_threads = 2

  # タイムアウト設定
  config.transport.timeout = 2
  config.transport.open_timeout = 1
end

# ============================================================
# ヘルパーメソッド
# ============================================================

def filter_sensitive_data(data)
  return data unless data.is_a?(Hash)

  sensitive_keys = %w[password password_confirmation token secret api_key]

  data.transform_values do |value|
    if sensitive_keys.any? { |key| value.to_s.downcase.include?(key) }
      "[FILTERED]"
    elsif value.is_a?(Hash)
      filter_sensitive_data(value)
    else
      value
    end
  end
end

# ============================================================
# 使用例
# ============================================================

# 例外のキャプチャ
# begin
#   risky_operation
# rescue => e
#   Sentry.capture_exception(e)
#   raise
# end

# 追加情報付きでキャプチャ
# Sentry.capture_exception(e, extra: {
#   user_id: current_user.id,
#   action: 'process_payment',
#   amount: amount
# })

# メッセージのキャプチャ
# Sentry.capture_message("Something went wrong", level: :warning)

# スコープの設定
# Sentry.configure_scope do |scope|
#   scope.set_user(id: user.id, email: user.email)
#   scope.set_tags(page: 'checkout')
#   scope.set_extra(order_id: order.id)
# end

# トランザクションの作成
# Sentry.start_transaction(name: 'process_order', op: 'task') do |transaction|
#   # 処理
# end
