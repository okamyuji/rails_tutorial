# frozen_string_literal: true

# New Relic設定
# config/newrelic.yml

# ============================================================
# 設定ファイル例
# ============================================================

# common: &default_settings
#   license_key: <%= ENV['NEW_RELIC_LICENSE_KEY'] %>
#   app_name: <%= ENV['NEW_RELIC_APP_NAME'] || 'My Rails App' %>
#
#   # ログ設定
#   log_level: info
#   log_file_path: 'log/newrelic_agent.log'
#
#   # 分散トレーシング
#   distributed_tracing:
#     enabled: true
#
#   # トランザクショントレーサー
#   transaction_tracer:
#     enabled: true
#     transaction_threshold: apdex_f
#     record_sql: obfuscated
#     stack_trace_threshold: 0.5
#
#   # エラーコレクター
#   error_collector:
#     enabled: true
#     ignore_errors: "ActionController::RoutingError,ActiveRecord::RecordNotFound"
#     capture_source: true
#
#   # ブラウザモニタリング
#   browser_monitoring:
#     auto_instrument: true
#
#   # カスタムインストルメンテーション
#   custom_insights_events:
#     enabled: true
#     max_samples_stored: 30000
#
# production:
#   <<: *default_settings
#   monitor_mode: true
#
# staging:
#   <<: *default_settings
#   monitor_mode: true
#   app_name: <%= ENV['NEW_RELIC_APP_NAME'] || 'My Rails App (Staging)' %>
#
# development:
#   <<: *default_settings
#   monitor_mode: false
#
# test:
#   <<: *default_settings
#   monitor_mode: false

# ============================================================
# カスタムインストルメンテーション
# ============================================================

# class PaymentService
#   include ::NewRelic::Agent::MethodTracer
#
#   def process_payment(amount)
#     # 処理
#   end
#   add_method_tracer :process_payment, 'Custom/PaymentService/process_payment'
# end

# ============================================================
# カスタムイベントの送信
# ============================================================

# NewRelic::Agent.record_custom_event('UserSignup', {
#   user_id: user.id,
#   plan: user.plan,
#   source: params[:source]
# })

# ============================================================
# カスタムメトリクスの記録
# ============================================================

# NewRelic::Agent.record_metric('Custom/Queue/Size', queue.size)
# NewRelic::Agent.increment_metric('Custom/Orders/Count')

# ============================================================
# エラーの手動送信
# ============================================================

# begin
#   risky_operation
# rescue => e
#   NewRelic::Agent.notice_error(e, custom_params: { user_id: current_user.id })
#   raise
# end

# ============================================================
# トランザクションの命名
# ============================================================

# NewRelic::Agent.set_transaction_name('WebTransaction/Custom/MyAction')

# ============================================================
# バックグラウンドトランザクション
# ============================================================

# class MyJob < ApplicationJob
#   include NewRelic::Agent::Instrumentation::ControllerInstrumentation
#
#   def perform
#     # 処理
#   end
#   add_transaction_tracer :perform, category: :task
# end

