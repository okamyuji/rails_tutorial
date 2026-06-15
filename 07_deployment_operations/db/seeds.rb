# サンプルデータの作成
# bin/rails db:seed で実行

user1 = User.find_or_create_by!(email: "taro@example.com") do |u|
  u.name = "田中太郎"
end

user2 = User.find_or_create_by!(email: "hanako@example.com") do |u|
  u.name = "鈴木花子"
end

article1 = Article.find_or_create_by!(title: "Railsチュートリアル第7章") do |a|
  a.user = user1
  a.content = "デプロイと運用について学びます。CI/CD、Docker、Kamalによるデプロイ、監視とログ管理を実践します。"
  a.published = true
  a.published_at = Time.current
end

article2 = Article.find_or_create_by!(title: "Solid Queueでバックグラウンドジョブ") do |a|
  a.user = user2
  a.content = "Rails 8ではSolid QueueがデフォルトのジョブバックエンドとしてRedisなしで非同期処理を実行できます。"
  a.published = true
  a.published_at = Time.current
end

article3 = Article.find_or_create_by!(title: "Logrageで構造化ログ") do |a|
  a.user = user1
  a.content = "LogrageでRailsのログをJSON形式に構造化し、CloudWatch LogsやDatadogで効率的に検索・分析できるようにします。"
  a.published = false
end

Comment.find_or_create_by!(article: article1, user: user2, body: "とてもわかりやすい記事です。")
Comment.find_or_create_by!(article: article2, user: user1, body: "Redisが不要になるのは運用が楽になりますね。")

puts "Seed data created: #{User.count} users, #{Article.count} articles, #{Comment.count} comments"
