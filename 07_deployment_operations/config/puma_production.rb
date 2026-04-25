# frozen_string_literal: true

# Puma本番環境設定
# config/puma.rb

# ============================================================
# 基本設定
# ============================================================

# ワーカー数（CPUコア数に基づく）
workers ENV.fetch("WEB_CONCURRENCY", 2)

# スレッド数
max_threads_count = ENV.fetch("RAILS_MAX_THREADS", 5)
min_threads_count = ENV.fetch("RAILS_MIN_THREADS") { max_threads_count }
threads min_threads_count, max_threads_count

# ポート
port ENV.fetch("PORT", 3000)

# 環境
environment ENV.fetch("RAILS_ENV", "development")

# プリロード
preload_app!

# ============================================================
# ワーカー設定
# ============================================================

# ワーカー起動時のフック
on_worker_boot do
  # データベース接続の再確立
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord)

  # Redis接続の再確立
  # Redis.current.ping if defined?(Redis)
end

# ワーカーフォーク前のフック
before_fork do
  # データベース接続を切断
  ActiveRecord::Base.connection_pool.disconnect! if defined?(ActiveRecord)
end

# ============================================================
# プロセス管理
# ============================================================

# PIDファイル
pidfile ENV.fetch("PIDFILE", "tmp/pids/server.pid")

# 状態ファイル（pumactl用）
state_path "tmp/pids/puma.state"

# ============================================================
# Phased Restart（ゼロダウンタイムデプロイ）
# ============================================================

# ワーカーのタイムアウト
worker_timeout 60

# フェーズドリスタートの有効化
# pumactl phased-restart で使用

# ============================================================
# ソケット設定（Nginx連携時）
# ============================================================

# UNIXソケット
# bind "unix://#{ENV.fetch('PUMA_SOCKET') { 'tmp/sockets/puma.sock' }}"

# TCPソケット
# bind "tcp://0.0.0.0:#{ENV.fetch('PORT') { 3000 }}"

# SSL設定
# ssl_bind '0.0.0.0', '9292', {
#   key: ENV.fetch('SSL_KEY_PATH'),
#   cert: ENV.fetch('SSL_CERT_PATH')
# }

# ============================================================
# 低レベル設定
# ============================================================

# ワーカーのシャットダウンタイムアウト
worker_shutdown_timeout 30

# ドレインタイムアウト
drain_timeout 30

# フォースシャットダウン
force_shutdown_after 60

# ============================================================
# メトリクス（オプション）
# ============================================================

# プラグインの有効化
# plugin :tmp_restart

# ============================================================
# 本番環境のチューニング例
# ============================================================

# 小規模（1GB RAM）
# workers 1
# threads 5, 5

# 中規模（2GB RAM）
# workers 2
# threads 5, 5

# 大規模（4GB+ RAM）
# workers 4
# threads 5, 5

# ============================================================
# Heroku設定
# ============================================================

# Procfile
# web: bundle exec puma -C config/puma.rb
