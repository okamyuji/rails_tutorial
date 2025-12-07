# frozen_string_literal: true

# パフォーマンス計測のデモンストレーション
# rails runner performance_demo.rb で実行します

puts '=' * 80
puts 'パフォーマンス計測のデモンストレーション'
puts '=' * 80
puts ''

puts '1. Bullet gem（N+1問題の検出）'
puts '-' * 40
puts ''

bullet_config = <<~RUBY
# Gemfile
group :development do
  gem 'bullet'
end

# config/environments/development.rb
config.after_initialize do
  Bullet.enable = true
  Bullet.alert = true           # ブラウザにアラート表示
  Bullet.bullet_logger = true   # log/bullet.logに記録
  Bullet.console = true         # ブラウザコンソールに出力
  Bullet.rails_logger = true    # Railsログに出力
  Bullet.add_footer = true      # ページフッターに表示
  
  # Slack通知（オプション）
  # Bullet.slack = {
  #   webhook_url: 'https://hooks.slack.com/...',
  #   channel: '#alerts'
  # }
end
RUBY

puts bullet_config
puts ''

n_plus_one_example = <<~RUBY
# N+1問題の例
# 悪い例: N+1クエリが発生
@articles = Article.all
@articles.each do |article|
  puts article.user.name      # 記事ごとにユーザーを取得
  puts article.comments.count # 記事ごとにコメント数を取得
end

# 良い例: Eager Loading
@articles = Article.includes(:user, :comments).all
@articles.each do |article|
  puts article.user.name
  puts article.comments.size  # sizeはキャッシュを使用
end

# Bulletの警告例:
# USE eager loading detected
#   Article => [:user]
#   Add to your query: .includes([:user])
RUBY

puts n_plus_one_example
puts ''

puts '2. rack-mini-profiler'
puts '-' * 40
puts ''

mini_profiler = <<~RUBY
# Gemfile
group :development do
  gem 'rack-mini-profiler'
  gem 'memory_profiler'
  gem 'stackprof'
end

# 使用方法
# サーバー起動後、ページ左上にプロファイル情報が表示される

# URLパラメータ:
# ?pp=disable          - プロファイラを無効化
# ?pp=enable           - プロファイラを有効化
# ?pp=profile-gc       - GCプロファイル
# ?pp=profile-memory   - メモリプロファイル
# ?pp=flamegraph       - フレームグラフ
# ?pp=flamegraph-hierarchical - 階層的フレームグラフ
# ?pp=async-flamegraph - 非同期フレームグラフ

# コードでの計測
Rack::MiniProfiler.step("Fetch articles") do
  @articles = Article.includes(:user, :comments).limit(100)
end

Rack::MiniProfiler.step("Process data") do
  @processed = @articles.map { |a| process(a) }
end
RUBY

puts mini_profiler
puts ''

puts '3. Benchmark'
puts '-' * 40
puts ''

benchmark_example = <<~RUBY
require 'benchmark'

# 基本的な計測
time = Benchmark.measure do
  1000.times { Article.all.to_a }
end
puts time

# 比較計測
Benchmark.bm(20) do |x|
  x.report("includes:") { Article.includes(:user).to_a }
  x.report("joins:") { Article.joins(:user).to_a }
  x.report("preload:") { Article.preload(:user).to_a }
end

# メモリ計測
require 'benchmark/memory'

Benchmark.memory do |x|
  x.report("map:") { (1..1000).map { |i| i * 2 } }
  x.report("each:") { arr = []; (1..1000).each { |i| arr << i * 2 }; arr }
  x.compare!
end

# IPS（Iterations Per Second）計測
require 'benchmark/ips'

Benchmark.ips do |x|
  x.report("map") { (1..1000).map { |i| i * 2 } }
  x.report("collect") { (1..1000).collect { |i| i * 2 } }
  x.compare!
end
RUBY

puts benchmark_example
puts ''

puts '4. ActiveSupport::Notifications'
puts '-' * 40
puts ''

notifications = <<~RUBY
# SQLクエリの監視
ActiveSupport::Notifications.subscribe('sql.active_record') do |name, start, finish, id, payload|
  duration = (finish - start) * 1000
  if duration > 100  # 100ms以上のクエリをログ
    Rails.logger.warn "Slow query (\#{duration.round(2)}ms): \#{payload[:sql]}"
  end
end

# コントローラアクションの監視
ActiveSupport::Notifications.subscribe('process_action.action_controller') do |name, start, finish, id, payload|
  duration = (finish - start) * 1000
  Rails.logger.info "Action \#{payload[:controller]}#\#{payload[:action]}: \#{duration.round(2)}ms"
end

# カスタムイベントの発行
ActiveSupport::Notifications.instrument('custom.event', extra: 'data') do
  # 計測したい処理
  expensive_operation
end

# カスタムイベントの購読
ActiveSupport::Notifications.subscribe('custom.event') do |name, start, finish, id, payload|
  Rails.logger.info "Custom event: \#{payload[:extra]}"
end
RUBY

puts notifications
puts ''

puts '5. クエリ最適化'
puts '-' * 40
puts ''

query_optimization = <<~RUBY
# EXPLAIN ANALYZE
Article.where(published: true).explain
# => EXPLAIN for: SELECT "articles".* FROM "articles" WHERE "articles"."published" = true

# クエリプランの詳細
Article.where(published: true).explain(:analyze)

# インデックスの確認
ActiveRecord::Base.connection.indexes(:articles)

# 遅いクエリの特定
# config/database.yml
# development:
#   log_queries: true
#   statement_limit: 1000

# クエリの最適化例
# 悪い例
Article.where("title LIKE ?", "%keyword%")

# 良い例（全文検索インデックスを使用）
Article.where("title @@ ?", "keyword")

# カウントの最適化
# 悪い例
Article.all.count  # SELECT COUNT(*) FROM articles

# 良い例（キャッシュを使用）
Rails.cache.fetch("articles_count", expires_in: 1.hour) do
  Article.count
end
RUBY

puts query_optimization
puts ''

puts '6. メモリプロファイリング'
puts '-' * 40
puts ''

memory_profiling = <<~RUBY
# memory_profiler gem
require 'memory_profiler'

report = MemoryProfiler.report do
  1000.times { Article.new(title: 'Test', content: 'Content') }
end

report.pretty_print

# derailed_benchmarks gem
# Gemfile
gem 'derailed_benchmarks', group: :development

# メモリ使用量の計測
# bundle exec derailed bundle:mem

# オブジェクト割り当ての計測
# bundle exec derailed bundle:objects

# GCの監視
GC.stat
# => { count: 10, heap_allocated_pages: 100, ... }

# ObjectSpaceでのオブジェクト数確認
ObjectSpace.count_objects
# => { TOTAL: 100000, FREE: 50000, T_OBJECT: 10000, ... }
RUBY

puts memory_profiling
puts ''

puts '7. 本番環境での監視'
puts '-' * 40
puts ''

production_monitoring = <<~RUBY
# New Relic
# Gemfile
gem 'newrelic_rpm'

# config/newrelic.yml
production:
  license_key: <%= ENV['NEW_RELIC_LICENSE_KEY'] %>
  app_name: My Rails App

# Datadog
# Gemfile
gem 'ddtrace'

# config/initializers/datadog.rb
Datadog.configure do |c|
  c.tracing.instrument :rails
  c.tracing.instrument :active_record
  c.tracing.instrument :redis
end

# Skylight
# Gemfile
gem 'skylight'

# config/skylight.yml
authentication: <%= ENV['SKYLIGHT_AUTHENTICATION'] %>

# Scout APM
# Gemfile
gem 'scout_apm'

# config/scout_apm.yml
production:
  key: <%= ENV['SCOUT_KEY'] %>
  name: My Rails App
RUBY

puts production_monitoring
puts ''

puts '=' * 80
puts 'パフォーマンス最適化のチェックリスト'
puts '=' * 80
puts ''

puts '1. N+1クエリを解消（Bullet使用）'
puts '2. 適切なインデックスを追加'
puts '3. 不要なカラムを選択しない（select使用）'
puts '4. ページネーションを実装'
puts '5. キャッシュを活用'
puts '6. バックグラウンドジョブを使用'
puts '7. CDNでアセットを配信'
puts ''

puts '=' * 80

