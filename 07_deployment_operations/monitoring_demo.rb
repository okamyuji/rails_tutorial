# frozen_string_literal: true

# 監視とログ管理のデモンストレーション
# rails runner monitoring_demo.rb で実行します

puts '=' * 80
puts '監視とログ管理のデモンストレーション'
puts '=' * 80
puts ''

puts '1. Railsログの設定'
puts '-' * 40
puts ''

log_config = <<~RUBY
# config/environments/production.rb
Rails.application.configure do
  # ログレベル
  config.log_level = :info

  # ログフォーマッタ
  config.log_formatter = ::Logger::Formatter.new

  # STDOUTへの出力（Docker/Heroku用）
  if ENV['RAILS_LOG_TO_STDOUT'].present?
    logger = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = config.log_formatter
    config.logger = ActiveSupport::TaggedLogging.new(logger)
  end
end
RUBY

puts log_config
puts ''

puts '2. Lograge（構造化ログ）'
puts '-' * 40
puts ''

lograge_config = <<~RUBY
# Gemfile
gem 'lograge'

# config/environments/production.rb
config.lograge.enabled = true
config.lograge.formatter = Lograge::Formatters::Json.new

# カスタムデータの追加
config.lograge.custom_options = lambda do |event|
  {
    time: Time.current.iso8601,
    user_id: event.payload[:user_id],
    ip: event.payload[:ip],
    request_id: event.payload[:request_id]
  }
end

# カスタムペイロードの追加（コントローラ側）
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  def append_info_to_payload(payload)
    super
    payload[:user_id] = current_user&.id
    payload[:ip] = request.remote_ip
    payload[:request_id] = request.request_id
  end
end

# 出力例（JSON形式）
# {"method":"GET","path":"/articles","status":200,"duration":45.2,"user_id":1,"ip":"192.168.1.1"}
RUBY

puts lograge_config
puts ''

puts '3. Sentry（エラー追跡）'
puts '-' * 40
puts ''

sentry_config = <<~RUBY
# Gemfile
gem 'sentry-ruby'
gem 'sentry-rails'

# config/initializers/sentry.rb
Sentry.init do |config|
  config.dsn = ENV['SENTRY_DSN']
  
  # 環境名
  config.environment = Rails.env
  
  # リリースバージョン
  config.release = ENV['GIT_COMMIT'] || `git rev-parse HEAD`.strip
  
  # パンくずリスト
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]
  
  # トレースサンプリング率
  config.traces_sample_rate = Rails.env.production? ? 0.1 : 1.0
  
  # 機密情報のフィルタリング
  config.send_default_pii = false
  
  # 除外するエラー
  config.excluded_exceptions += [
    'ActionController::RoutingError',
    'ActiveRecord::RecordNotFound'
  ]
end

# 手動でエラーを送信
begin
  risky_operation
rescue => e
  Sentry.capture_exception(e, extra: { user_id: current_user.id })
  raise
end

# カスタムメッセージの送信
Sentry.capture_message("Something went wrong", level: :warning)
RUBY

puts sentry_config
puts ''

puts '4. New Relic（APM）'
puts '-' * 40
puts ''

newrelic_config = <<~RUBY
# Gemfile
gem 'newrelic_rpm'

# config/newrelic.yml
common: &default_settings
  license_key: <%= ENV['NEW_RELIC_LICENSE_KEY'] %>
  app_name: My Rails App
  
  # 分散トレーシング
  distributed_tracing:
    enabled: true
  
  # トランザクショントレーサー
  transaction_tracer:
    enabled: true
    record_sql: obfuscated
  
  # エラーコレクター
  error_collector:
    enabled: true
    ignore_errors: "ActionController::RoutingError"

production:
  <<: *default_settings
  monitor_mode: true

development:
  <<: *default_settings
  monitor_mode: false

test:
  <<: *default_settings
  monitor_mode: false
RUBY

puts newrelic_config
puts ''

puts '5. Datadog'
puts '-' * 40
puts ''

datadog_config = <<~RUBY
# Gemfile
gem 'ddtrace'

# config/initializers/datadog.rb
Datadog.configure do |c|
  c.service = 'my-rails-app'
  c.env = Rails.env
  
  # Railsの自動インストルメンテーション
  c.tracing.instrument :rails
  c.tracing.instrument :active_record
  c.tracing.instrument :redis
  c.tracing.instrument :sidekiq
  
  # サンプリング率
  c.tracing.sampling.default_rate = Rails.env.production? ? 0.1 : 1.0
  
  # ログ相関
  c.tracing.log_injection = true
end
RUBY

puts datadog_config
puts ''

puts '6. ヘルスチェックエンドポイント'
puts '-' * 40
puts ''

health_check = <<~RUBY
# config/routes.rb
Rails.application.routes.draw do
  get '/health', to: 'health#show'
  get '/health/live', to: 'health#live'
  get '/health/ready', to: 'health#ready'
end

# app/controllers/health_controller.rb
class HealthController < ApplicationController
  skip_before_action :authenticate_user!, raise: false

  def show
    render json: {
      status: 'ok',
      timestamp: Time.current.iso8601,
      version: ENV['GIT_COMMIT'] || 'unknown'
    }
  end

  def live
    render json: { status: 'ok' }
  end

  def ready
    checks = {
      database: database_connected?,
      redis: redis_connected?,
      sidekiq: sidekiq_running?
    }

    if checks.values.all?
      render json: { status: 'ok', checks: checks }
    else
      render json: { status: 'error', checks: checks }, status: :service_unavailable
    end
  end

  private

  def database_connected?
    ActiveRecord::Base.connection.active?
  rescue
    false
  end

  def redis_connected?
    Redis.current.ping == 'PONG'
  rescue
    false
  end

  def sidekiq_running?
    Sidekiq::ProcessSet.new.size > 0
  rescue
    false
  end
end
RUBY

puts health_check
puts ''

puts '=' * 80
puts '監視のベストプラクティス'
puts '=' * 80
puts ''

puts '1. 構造化ログを使用（JSON形式）'
puts '2. エラー追跡サービスを設定（Sentry/Rollbar）'
puts '3. APMでパフォーマンスを監視（New Relic/Datadog）'
puts '4. ヘルスチェックエンドポイントを実装'
puts '5. アラートを設定（エラー率、レスポンスタイム）'
puts ''

puts '=' * 80

