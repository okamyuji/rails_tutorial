# frozen_string_literal: true

# Lograge設定
# config/initializers/lograge.rb

Rails.application.configure do
  # Logrageの有効化
  config.lograge.enabled = true

  # JSON形式で出力
  config.lograge.formatter = Lograge::Formatters::Json.new

  # カスタムオプション
  config.lograge.custom_options = lambda do |event|
    {
      # タイムスタンプ
      time: Time.current.iso8601,

      # リクエストID
      request_id: event.payload[:request_id],

      # ユーザーID
      user_id: event.payload[:user_id],

      # IPアドレス
      ip: event.payload[:ip],

      # User Agent
      user_agent: event.payload[:user_agent],

      # リファラー
      referer: event.payload[:referer],

      # パラメータ（フィルタリング済み）
      params: event.payload[:params]&.except('controller', 'action', 'format'),

      # 例外情報
      exception: event.payload[:exception]&.first,
      exception_message: event.payload[:exception_object]&.message
    }.compact
  end

  # カスタムペイロード（ApplicationControllerで設定）
  config.lograge.custom_payload do |controller|
    {
      host: controller.request.host,
      remote_ip: controller.request.remote_ip
    }
  end

  # 無視するアクション
  config.lograge.ignore_actions = [
    'HealthController#show',
    'HealthController#live',
    'HealthController#ready'
  ]

  # 無視するパス
  # config.lograge.ignore_custom = lambda do |event|
  #   event.payload[:path].start_with?('/assets')
  # end

  # ログに含めるヘッダー
  config.lograge.keep_original_rails_log = false
end

# ============================================================
# ApplicationControllerでのペイロード追加
# ============================================================

# class ApplicationController < ActionController::Base
#   def append_info_to_payload(payload)
#     super
#     payload[:request_id] = request.request_id
#     payload[:user_id] = current_user&.id
#     payload[:ip] = request.remote_ip
#     payload[:user_agent] = request.user_agent
#     payload[:referer] = request.referer
#   end
# end

# ============================================================
# 出力例
# ============================================================

# {
#   "method": "GET",
#   "path": "/articles",
#   "format": "html",
#   "controller": "ArticlesController",
#   "action": "index",
#   "status": 200,
#   "duration": 45.23,
#   "view": 30.12,
#   "db": 10.45,
#   "time": "2024-01-15T10:30:00+09:00",
#   "request_id": "abc123",
#   "user_id": 1,
#   "ip": "192.168.1.1"
# }

# ============================================================
# ログの集約サービス
# ============================================================

# Papertrail
# config.lograge.logger = RemoteSyslogLogger.new('logs.papertrailapp.com', 12345)

# Loggly
# config.lograge.logger = LogglyLogger.new('your-loggly-token')

# CloudWatch Logs
# AWS::Rails.add_action_controller_logger

