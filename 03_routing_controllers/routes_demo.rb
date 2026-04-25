# frozen_string_literal: true

# ルーティングのデモンストレーション
# rails runner routes_demo.rb で実行します

puts "=" * 80
puts "ルーティングのデモンストレーション"
puts "=" * 80
puts ""

puts "定義されているルート一覧:"
puts "-" * 80
puts ""

# すべてのルートを取得
routes = Rails.application.routes.routes

# APIルートのみをフィルタリング
api_routes = routes.select { |r| r.path.spec.to_s.start_with?("/api/v1") }

puts "合計 #{api_routes.count} 個のAPIルートが定義されています"
puts ""

# ルートをグループ化して表示
grouped_routes = api_routes.group_by { |route| route.defaults[:controller] }

grouped_routes.each do |controller, controller_routes|
  puts "Controller: #{controller}"
  puts "-" * 40

  controller_routes.each do |route|
    verb = route.verb.to_s.ljust(7)
    path = route.path.spec.to_s.ljust(50)
    action = route.defaults[:action]

    puts "  #{verb} #{path} → #{action}"
  end

  puts ""
end

puts "=" * 80
puts "ルーティングの詳細分析"
puts "=" * 80
puts ""

# Articlesコントローラのルート
puts "1. Articlesコントローラのルート:"
puts "-" * 40
puts ""

article_routes =
  api_routes.select { |r| r.defaults[:controller] == "api/v1/articles" }
article_routes.each do |route|
  verb = route.verb.to_s.ljust(7)
  path = route.path.spec.to_s
  action = route.defaults[:action]

  description =
    case action
    when "index"
      "記事の一覧を取得"
    when "show"
      "特定の記事を取得"
    when "create"
      "新しい記事を作成"
    when "update"
      "記事を更新"
    when "destroy"
      "記事を削除"
    when "publish"
      "記事を公開"
    when "unpublish"
      "記事を非公開"
    when "published"
      "公開済み記事の一覧"
    else
      "その他の操作"
    end

  puts "  #{verb} #{path}"
  puts "    → #{description}"
  puts ""
end

# Commentsコントローラのルート
puts "2. Commentsコントローラのルート:"
puts "-" * 40
puts ""

comment_routes =
  api_routes.select { |r| r.defaults[:controller] == "api/v1/comments" }
comment_routes.each do |route|
  verb = route.verb.to_s.ljust(7)
  path = route.path.spec.to_s
  action = route.defaults[:action]

  nested = path.include?("article_id")
  description =
    case action
    when "index"
      nested ? "特定記事のコメント一覧" : "すべてのコメント一覧"
    when "show"
      "コメントの詳細"
    when "create"
      "新しいコメントを作成"
    when "update"
      "コメントを更新"
    when "destroy"
      "コメントを削除"
    else
      "その他の操作"
    end

  puts "  #{verb} #{path}"
  puts "    → #{description}"
  puts ""
end

puts "=" * 80
puts "URLヘルパーの使用例"
puts "=" * 80
puts ""

# URLヘルパーの例を表示
if defined?(Rails.application.routes.url_helpers)
  helpers = Rails.application.routes.url_helpers

  puts "記事関連:"
  puts "  api_v1_articles_path              → #{helpers.api_v1_articles_path}"
  puts "  api_v1_article_path(1)            → #{helpers.api_v1_article_path(1)}"
  puts ""

  puts "コメント関連:"
  puts "  api_v1_article_comments_path(1)   → #{helpers.api_v1_article_comments_path(1)}"
  puts "  api_v1_comment_path(1)            → #{helpers.api_v1_comment_path(1)}"
  puts ""

  puts "ユーザー関連:"
  puts "  api_v1_users_path                 → #{helpers.api_v1_users_path}"
  puts "  api_v1_user_path(1)               → #{helpers.api_v1_user_path(1)}"
  puts ""
end

puts "=" * 80
puts "ルーティングのベストプラクティス"
puts "=" * 80
puts ""

puts "1. RESTfulな設計:"
puts "   - 標準的な7つのアクションを優先"
puts "   - HTTPメソッド（GET, POST, PATCH, DELETE）を適切に使用"
puts "   - URLがリソースの構造を明確に表現"
puts ""

puts "2. ネストの制限:"
puts "   - ネストは1段階に留める"
puts "   - shallowオプションを活用"
puts "   - 深いネストはURLを複雑にする"
puts ""

puts "3. カスタムアクション:"
puts "   - 最小限に留める"
puts "   - 新しいリソースとして切り出せないか検討"
puts "   - member: 特定のリソースへの操作"
puts "   - collection: リソース全体への操作"
puts ""

puts "4. バージョニング:"
puts "   - API仕様の変更に備える"
puts "   - 名前空間（api/v1）を使用"
puts "   - 後方互換性を維持"
puts ""

puts "5. ルートの確認方法:"
puts "   - rails routes: すべてのルートを表示"
puts "   - rails routes -g articles: articlesを含むルートのみ"
puts "   - rails routes -c articles: ArticlesControllerのルートのみ"
puts ""

puts "=" * 80
