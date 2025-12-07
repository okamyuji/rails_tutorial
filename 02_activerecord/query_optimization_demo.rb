# frozen_string_literal: true

# クエリ最適化のデモンストレーション
# rails runner query_optimization_demo.rb で実行します

puts "=" * 80
puts "クエリ最適化のデモンストレーション"
puts "=" * 80
puts ""

# データが存在するか確認
if User.count == 0
  puts "エラー: サンプルデータが存在しません"
  puts "まず seed_data.rb を実行してください"
  exit 1
end

puts "デモ1: scopeの使用"
puts "-" * 40
puts ""

puts "公開済みの記事を新しい順に5件取得:"
articles = Article.published.recent.limit(5)
articles.each do |article|
  puts "  - #{article.title} (#{article.published_at.strftime('%Y-%m-%d')})"
end
puts ""

puts "実行されたSQL:"
puts Article.published.recent.limit(5).to_sql
puts ""

puts "成人ユーザーを最近登録順に取得:"
users = User.adult.recent.limit(5)
users.each do |user|
  puts "  - #{user.name} (#{user.age}歳)"
end
puts ""

puts "=" * 80
puts "デモ2: joinsとincludesの使い分け"
puts "-" * 40
puts ""

puts "joins: 公開済み記事を持つユーザーを取得（記事データは取得しない）"
users = User.joins(:articles).where(articles: { published: true }).distinct
puts "取得したユーザー数: #{users.count}"
users.limit(3).each do |user|
  puts "  - #{user.name}"
end
puts ""

puts "実行されたSQL:"
puts User.joins(:articles).where(articles: { published: true }).distinct.limit(3).to_sql
puts ""

puts "includes: ユーザーと記事データの両方を取得"
users = User.includes(:articles).limit(3)
users.each do |user|
  puts "  - #{user.name}: #{user.articles.count} articles"
  user.articles.first(2).each do |article|
    puts "      - #{article.title}"
  end
end
puts ""

puts "=" * 80
puts "デモ3: selectによる必要なカラムのみの取得"
puts "-" * 40
puts ""

puts "すべてのカラムを取得:"
users = User.limit(3)
puts "取得したデータ:"
users.each do |user|
  puts "  - #{user.attributes.keys.join(', ')}"
  break  # 1件だけ表示
end
puts ""

puts "必要なカラムのみを取得:"
users = User.select(:id, :name, :email).limit(3)
puts "取得したデータ:"
users.each do |user|
  puts "  - #{user.attributes.keys.join(', ')}"
  break  # 1件だけ表示
end
puts ""

puts "実行されたSQL:"
puts User.select(:id, :name, :email).limit(3).to_sql
puts ""

puts "=" * 80
puts "デモ4: pluckによる特定の値の配列取得"
puts "-" * 40
puts ""

puts "ユーザー名の配列を取得:"
names = User.limit(5).pluck(:name)
puts names.inspect
puts ""

puts "IDとメールアドレスのハッシュを取得:"
user_data = User.limit(5).pluck(:id, :email)
user_data.each do |id, email|
  puts "  ID: #{id}, Email: #{email}"
end
puts ""

puts "pluckの利点:"
puts "  - モデルインスタンスを生成しないため高速"
puts "  - メモリ使用量が少ない"
puts "  - 単純な値の取得に最適"
puts ""

puts "=" * 80
puts "デモ5: existsによる存在確認"
puts "-" * 40
puts ""

first_user = User.first

puts "記事の存在確認（count使用）:"
has_articles_count = first_user.articles.count > 0
puts "  結果: #{has_articles_count}"
puts "  問題: countはすべてのレコードを数える"
puts ""

puts "記事の存在確認（exists使用）:"
has_articles_exists = first_user.articles.exists?
puts "  結果: #{has_articles_exists}"
puts "  利点: 1件でも見つかれば即座に返る"
puts ""

puts "実行されたSQL（exists）:"
puts first_user.articles.exists?.to_s
puts ""

puts "=" * 80
puts "デモ6: batchesによる大量データの処理"
puts "-" * 40
puts ""

puts "find_eachを使用した大量データの処理:"
puts "（メモリ効率的にユーザーを処理）"
puts ""

count = 0
User.find_each(batch_size: 5) do |user|
  count += 1
  puts "  処理中: #{user.name}" if count <= 3
  puts "  ..." if count == 4
end
puts ""
puts "合計 #{count} 人のユーザーを処理しました"
puts ""

puts "find_eachの利点:"
puts "  - 大量のレコードを一度にメモリに読み込まない"
puts "  - バッチサイズを指定できる（デフォルト: 1000）"
puts "  - メモリ使用量を抑えられる"
puts ""

puts "=" * 80
puts "デモ7: eager_loadとpreload"
puts "-" * 40
puts ""

puts "eager_load: LEFT OUTER JOIN で一度に取得"
users = User.eager_load(:articles).limit(3)
puts "取得したユーザー数: #{users.count}"
puts ""

puts "実行されたSQL:"
puts User.eager_load(:articles).limit(3).to_sql
puts ""

puts "preload: 別々のクエリで取得"
users = User.preload(:articles).limit(3)
puts "取得したユーザー数: #{users.count}"
puts ""

puts "使い分け:"
puts "  - includes: Railsが最適な方法を自動選択"
puts "  - eager_load: 必ずJOINを使用したい場合"
puts "  - preload: 必ず別クエリで取得したい場合"
puts ""

puts "=" * 80
puts "デモ8: カウンターキャッシュ"
puts "-" * 40
puts ""

first_user = User.includes(:articles).first

puts "通常のカウント（記事テーブルにクエリ）:"
puts "  #{first_user.name}の記事数: #{first_user.articles.size}"
puts ""

puts "カウンターキャッシュを使用すると:"
puts "  - articlesテーブルにクエリを発行しない"
puts "  - usersテーブルのarticles_countカラムから取得"
puts "  - 大幅な高速化が可能"
puts ""

puts "実装方法:"
puts "  1. マイグレーションでカラムを追加:"
puts "     add_column :users, :articles_count, :integer, default: 0"
puts "  2. モデルに設定を追加:"
puts "     belongs_to :user, counter_cache: true"
puts ""

puts "=" * 80
puts "デモ9: クエリのチェーン"
puts "-" * 40
puts ""

puts "複数のスコープを組み合わせる:"
articles = Article.published.recent
  .joins(:user)
  .where(users: { age: 20..30 })
  .limit(5)

puts "実行されたSQL:"
puts articles.to_sql
puts ""

puts "取得した記事:"
articles.each do |article|
  puts "  - #{article.title} by #{article.user.name} (#{article.user.age}歳)"
end
puts ""

puts "=" * 80
puts "まとめ"
puts "=" * 80
puts ""

puts "クエリ最適化のテクニック:"
puts ""

puts "1. N+1問題の解決"
puts "   - includes, eager_load, preload を使用"
puts ""

puts "2. 必要なデータのみ取得"
puts "   - select: 必要なカラムのみ"
puts "   - pluck: 値の配列を直接取得"
puts ""

puts "3. 効率的な存在確認"
puts "   - exists?: countよりも高速"
puts "   - any?: 存在確認に最適"
puts ""

puts "4. 大量データの処理"
puts "   - find_each, find_in_batches"
puts "   - メモリ効率的な処理"
puts ""

puts "5. クエリの組み合わせ"
puts "   - スコープのチェーン"
puts "   - 可読性の高いクエリ"
puts ""

puts "6. 計測と最適化"
puts "   - SQLログを確認"
puts "   - EXPLAINで実行計画を分析"
puts "   - ボトルネックを特定"
puts ""

puts "=" * 80
