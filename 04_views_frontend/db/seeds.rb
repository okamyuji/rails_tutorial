# シードデータの作成
# bin/rails db:seed で実行

puts "Creating seed data..."

# ユーザーの作成
users = []
3.times do |i|
  users << User.find_or_create_by!(email: "user#{i + 1}@example.com") do |u|
    u.name = "User #{i + 1}"
  end
end

puts "Created #{users.size} users"

# 記事の作成
articles = []
users.each do |user|
  3.times do |i|
    articles << Article.find_or_create_by!(
      title: "#{user.name} の記事 #{i + 1}",
      user: user
    ) do |a|
      a.content = "これは #{user.name} が投稿した記事の本文です。" \
                   "Railsのビューとフロントエンド統合について学びましょう。" \
                   "パーシャル、Turbo、Stimulusなどの仕組みを使います。"
      a.published = i.even?
      a.published_at = Time.current if i.even?
    end
  end
end

puts "Created #{articles.size} articles"

# コメントの作成
articles.each do |article|
  commenter = users.reject { |u| u == article.user }.sample
  Comment.find_or_create_by!(
    article: article,
    user: commenter,
    body: "#{article.title} についてのコメントです。"
  )
end

puts "Created comments"
puts "Seed data creation complete!"
