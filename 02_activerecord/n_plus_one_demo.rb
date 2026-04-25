# frozen_string_literal: true

# N+1問題のデモンストレーション
# rails runner n_plus_one_demo.rb で実行します

require "benchmark"

puts "=" * 80
puts "N+1問題のデモンストレーション"
puts "=" * 80
puts ""

# データが存在するか確認
if User.none?
  puts "エラー: サンプルデータが存在しません"
  puts "まず seed_data.rb を実行してください"
  puts "  rails runner seed_data.rb"
  exit 1
end

# SQLログを有効化
ActiveRecord::Base.logger = Logger.new($stdout)
ActiveRecord::Base.logger.level = Logger::INFO

puts "デモ1: N+1問題が発生するケース"
puts "-" * 40
puts ""

# クエリ数をカウント
query_count = 0
original_log = ActiveRecord::Base.logger
counter_log = Logger.new($stdout)
counter_log.formatter =
  proc do |_severity, _datetime, _progname, msg|
    query_count += 1 if msg.include?("SELECT")
    msg
  end
ActiveRecord::Base.logger = counter_log

puts "10人のユーザーとその記事を取得します（N+1問題あり）"
puts ""

time =
  Benchmark.realtime do
    users = User.limit(10)
    users.each { |user| puts "#{user.name}: #{user.articles.count} articles" }
  end

puts ""
puts "実行されたSELECTクエリ数: #{query_count}"
puts "実行時間: #{(time * 1000).round(2)}ms"
puts ""

puts "説明:"
puts "  1回目のクエリ: 10人のユーザーを取得"
puts "  2回目以降: 各ユーザーの記事数を取得（10回）"
puts "  合計: #{query_count}回のクエリが実行されました"
puts ""

# リセット
query_count = 0

puts "=" * 80
puts "デモ2: includesを使用してN+1問題を解決"
puts "-" * 40
puts ""

puts "同じデータをincludesを使用して取得します"
puts ""

time =
  Benchmark.realtime do
    users = User.includes(:articles).limit(10)
    users.each { |user| puts "#{user.name}: #{user.articles.count} articles" }
  end

puts ""
puts "実行されたSELECTクエリ数: #{query_count}"
puts "実行時間: #{(time * 1000).round(2)}ms"
puts ""

puts "説明:"
puts "  1回目のクエリ: 10人のユーザーを取得"
puts "  2回目のクエリ: 10人分の記事を一括取得"
puts "  合計: #{query_count}回のクエリが実行されました"
puts ""

# ログを元に戻す
ActiveRecord::Base.logger = original_log

puts "=" * 80
puts "デモ3: より複雑なケース（ネストした関連）"
puts "-" * 40
puts ""

query_count = 0
ActiveRecord::Base.logger = counter_log

puts "ユーザー、記事、コメントを取得します（N+1問題あり）"
puts ""

time_bad =
  Benchmark.realtime do
    users = User.limit(5)
    users.each do |user|
      puts "#{user.name}:"
      user.articles.each do |article|
        puts "  - #{article.title} (#{article.comments.count} comments)"
      end
    end
  end

queries_bad = query_count
puts ""
puts "実行されたクエリ数: #{queries_bad}"
puts "実行時間: #{(time_bad * 1000).round(2)}ms"
puts ""

# リセット
query_count = 0

puts "同じデータをincludesを使用して取得します"
puts ""

time_good =
  Benchmark.realtime do
    users = User.includes(articles: :comments).limit(5)
    users.each do |user|
      puts "#{user.name}:"
      user.articles.each do |article|
        puts "  - #{article.title} (#{article.comments.count} comments)"
      end
    end
  end

queries_good = query_count
puts ""
puts "実行されたクエリ数: #{queries_good}"
puts "実行時間: #{(time_good * 1000).round(2)}ms"
puts ""

# ログを元に戻す
ActiveRecord::Base.logger = original_log

puts "=" * 80
puts "比較結果"
puts "=" * 80
puts ""

puts "N+1問題あり:"
puts "  クエリ数: #{queries_bad}"
puts "  実行時間: #{(time_bad * 1000).round(2)}ms"
puts ""

puts "includesで最適化:"
puts "  クエリ数: #{queries_good}"
puts "  実行時間: #{(time_good * 1000).round(2)}ms"
puts ""

puts "改善:"
puts "  クエリ数削減: #{queries_bad - queries_good}回 (#{((1 - (queries_good.to_f / queries_bad)) * 100).round(1)}%削減)"
puts "  速度向上: #{(time_bad / time_good).round(2)}倍高速化"
puts ""

puts "=" * 80
puts "まとめ"
puts "=" * 80
puts ""

puts "N+1問題とは:"
puts "  関連データを取得する際に、N個のレコードに対して"
puts "  N回の追加クエリが実行されてしまう問題です。"
puts ""

puts "解決方法:"
puts "  includes メソッドを使用して、関連データを事前に読み込みます。"
puts "  これにより、クエリ数を大幅に削減できます。"
puts ""

puts "使い分け:"
puts "  - includes: 関連データにアクセスする予定がある場合"
puts "  - joins: 関連テーブルで絞り込むだけの場合"
puts "  - eager_load: 必ず LEFT OUTER JOIN を使用したい場合"
puts "  - preload: 必ず別々のクエリで取得したい場合"
puts ""

puts "=" * 80
