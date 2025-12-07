# frozen_string_literal: true

# Datadog設定
# config/initializers/datadog.rb

Datadog.configure do |c|
  # サービス名
  c.service = ENV['DD_SERVICE'] || 'rails-app'

  # 環境名
  c.env = Rails.env

  # バージョン
  c.version = ENV['GIT_COMMIT'] || '1.0.0'

  # ============================================================
  # トレーシング設定
  # ============================================================

  # Rails
  c.tracing.instrument :rails

  # ActiveRecord
  c.tracing.instrument :active_record

  # Redis
  c.tracing.instrument :redis

  # Sidekiq
  c.tracing.instrument :sidekiq

  # HTTP
  c.tracing.instrument :http
  c.tracing.instrument :faraday
  c.tracing.instrument :httpclient

  # GraphQL（使用している場合）
  # c.tracing.instrument :graphql

  # gRPC（使用している場合）
  # c.tracing.instrument :grpc

  # ============================================================
  # サンプリング設定
  # ============================================================

  # サンプリング率
  c.tracing.sampling.default_rate = Rails.env.production? ? 0.1 : 1.0

  # 優先度サンプリング
  c.tracing.sampling.rate_limit = 100

  # ============================================================
  # ログ相関
  # ============================================================

  # ログにトレースIDを追加
  c.tracing.log_injection = true

  # ============================================================
  # ランタイムメトリクス
  # ============================================================

  # ランタイムメトリクスの有効化
  c.runtime_metrics.enabled = true

  # ============================================================
  # プロファイリング
  # ============================================================

  # プロファイリングの有効化
  c.profiling.enabled = ENV['DD_PROFILING_ENABLED'] == 'true'

  # ============================================================
  # その他の設定
  # ============================================================

  # デバッグモード
  c.diagnostics.debug = Rails.env.development?

  # タグの追加
  c.tags = {
    'team' => 'backend',
    'component' => 'web'
  }
end

# ============================================================
# カスタムスパンの作成
# ============================================================

# Datadog::Tracing.trace('custom.operation') do |span|
#   span.set_tag('user.id', current_user.id)
#   span.set_tag('order.id', order.id)
#
#   # 処理
#   result = process_order(order)
#
#   span.set_tag('order.status', result.status)
# end

# ============================================================
# カスタムメトリクスの送信
# ============================================================

# statsd = Datadog::Statsd.new('localhost', 8125)
#
# # カウンター
# statsd.increment('orders.created')
#
# # ゲージ
# statsd.gauge('queue.size', queue.size)
#
# # ヒストグラム
# statsd.histogram('request.duration', duration)
#
# # タイミング
# statsd.timing('database.query', query_time)

# ============================================================
# エラーの追跡
# ============================================================

# begin
#   risky_operation
# rescue => e
#   Datadog::Tracing.active_span&.set_error(e)
#   raise
# end

# ============================================================
# ログの設定（lograge連携）
# ============================================================

# config/environments/production.rb
# config.lograge.custom_options = lambda do |event|
#   {
#     dd: {
#       trace_id: Datadog::Tracing.correlation.trace_id,
#       span_id: Datadog::Tracing.correlation.span_id
#     }
#   }
# end

