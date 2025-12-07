# frozen_string_literal: true

# 本番環境データベース設定
# config/database.yml の production セクション例

# ============================================================
# PostgreSQL設定例
# ============================================================

# config/database.yml
#
# production:
#   adapter: postgresql
#   encoding: unicode
#   pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
#   url: <%= ENV['DATABASE_URL'] %>
#
#   # または個別に指定
#   host: <%= ENV['DB_HOST'] %>
#   port: <%= ENV['DB_PORT'] || 5432 %>
#   database: <%= ENV['DB_NAME'] %>
#   username: <%= ENV['DB_USERNAME'] %>
#   password: <%= ENV['DB_PASSWORD'] %>
#
#   # SSL設定
#   sslmode: require
#   sslrootcert: /path/to/ca-certificate.crt
#
#   # コネクションプール設定
#   pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
#   timeout: 5000
#   checkout_timeout: 5
#   reaping_frequency: 10
#
#   # プリペアドステートメント
#   prepared_statements: true

# ============================================================
# MySQL設定例
# ============================================================

# production:
#   adapter: mysql2
#   encoding: utf8mb4
#   collation: utf8mb4_unicode_ci
#   pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
#   url: <%= ENV['DATABASE_URL'] %>
#
#   # SSL設定
#   ssl_mode: VERIFY_IDENTITY
#   sslca: /path/to/ca-certificate.crt

# ============================================================
# レプリカ設定（読み取り分散）
# ============================================================

# production:
#   primary:
#     adapter: postgresql
#     url: <%= ENV['PRIMARY_DATABASE_URL'] %>
#   primary_replica:
#     adapter: postgresql
#     url: <%= ENV['REPLICA_DATABASE_URL'] %>
#     replica: true

# ============================================================
# マルチデータベース設定
# ============================================================

# production:
#   primary:
#     adapter: postgresql
#     url: <%= ENV['PRIMARY_DATABASE_URL'] %>
#   analytics:
#     adapter: postgresql
#     url: <%= ENV['ANALYTICS_DATABASE_URL'] %>
#     migrations_paths: db/analytics_migrate

# ============================================================
# コネクションプールの最適化
# ============================================================

# Pumaの場合
# config/puma.rb
#
# workers ENV.fetch("WEB_CONCURRENCY") { 2 }
# threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
# threads threads_count, threads_count
#
# on_worker_boot do
#   ActiveRecord::Base.establish_connection
# end

# Sidekiqの場合
# config/initializers/sidekiq.rb
#
# Sidekiq.configure_server do |config|
#   config.redis = { url: ENV['REDIS_URL'] }
#
#   database_url = ENV['DATABASE_URL']
#   if database_url
#     ActiveRecord::Base.establish_connection(
#       "#{database_url}?pool=#{ENV['SIDEKIQ_DB_POOL'] || 25}"
#     )
#   end
# end

# ============================================================
# データベースのヘルスチェック
# ============================================================

# ActiveRecord::Base.connection.active?
# ActiveRecord::Base.connection.execute("SELECT 1")

