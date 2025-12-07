# frozen_string_literal: true

# サンプルデータを生成するスクリプト
# rails runner seed_data.rb で実行します

puts "=" * 80
puts "サンプルデータの生成を開始します"
puts "=" * 80
puts ""

# 既存のデータをクリア（開発環境でのみ実行）
if Rails.env.development?
  puts "既存のデータをクリアしています..."
  [Comment, Article, Membership, User, Group].each do |model|
    model.destroy_all
  end
  puts "完了"
  puts ""
end

# ユーザーの作成
puts "ユーザーを作成しています..."
users = []

10.times do |i|
  user = User.create!(
    name: "User #{i + 1}",
    email: "user#{i + 1}@example.com",
    age: rand(18..65)
  )
  users << user
  print "."
end

puts " 完了（#{users.count}人のユーザーを作成）"
puts ""

# グループの作成
puts "グループを作成しています..."
groups = []

5.times do |i|
  group = Group.create!(
    name: "Group #{i + 1}",
    description: "This is a sample group number #{i + 1} for testing purposes."
  )
  groups << group
  print "."
end

puts " 完了（#{groups.count}個のグループを作成）"
puts ""

# メンバーシップの作成（ユーザーをグループに追加）
puts "メンバーシップを作成しています..."
membership_count = 0

users.each do |user|
  # 各ユーザーをランダムに1-3個のグループに追加
  sample_groups = groups.sample(rand(1..3))
  
  sample_groups.each do |group|
    role = [:member, :moderator, :admin].sample
    Membership.create!(
      user: user,
      group: group,
      role: role
    )
    membership_count += 1
    print "."
  end
end

puts " 完了（#{membership_count}個のメンバーシップを作成）"
puts ""

# 記事の作成
puts "記事を作成しています..."
articles = []

users.each do |user|
  # 各ユーザーがランダムに2-5個の記事を作成
  rand(2..5).times do |i|
    published = [true, false].sample
    
    article = user.articles.create!(
      title: "Article by #{user.name} - Part #{i + 1}",
      content: "This is the content of article #{i + 1} written by #{user.name}. " * 5,
      published: published,
      published_at: published ? rand(1..30).days.ago : nil
    )
    articles << article
    print "."
  end
end

puts " 完了（#{articles.count}個の記事を作成）"
puts ""

# コメントの作成
puts "コメントを作成しています..."
comment_count = 0

articles.each do |article|
  # 各記事にランダムに0-5個のコメントを追加
  rand(0..5).times do |i|
    commenter = users.sample
    
    Comment.create!(
      user: commenter,
      article: article,
      content: "This is comment #{i + 1} on article '#{article.title}' by #{commenter.name}"
    )
    comment_count += 1
    print "."
  end
end

puts " 完了（#{comment_count}個のコメントを作成）"
puts ""

# 結果のサマリーを表示
puts "=" * 80
puts "サンプルデータの生成が完了しました"
puts "=" * 80
puts ""

puts "生成されたデータ:"
puts "  ユーザー数: #{User.count}"
puts "  グループ数: #{Group.count}"
puts "  メンバーシップ数: #{Membership.count}"
puts "  記事数: #{Article.count}"
puts "    - 公開済み: #{Article.published.count}"
puts "    - 下書き: #{Article.draft.count}"
puts "  コメント数: #{Comment.count}"
puts ""

# サンプルクエリを実行
puts "サンプルクエリを実行します:"
puts "-" * 40
puts ""

# 最初のユーザーの情報を表示
first_user = User.first
puts "最初のユーザー:"
puts "  名前: #{first_user.name}"
puts "  メール: #{first_user.email}"
puts "  記事数: #{first_user.articles.count}"
puts "  公開済み記事数: #{first_user.published_articles.count}"
puts "  コメント数: #{first_user.comments.count}"
puts "  所属グループ数: #{first_user.groups.count}"
puts ""

# 最初の記事の情報を表示
first_article = Article.published.first
if first_article
  puts "最初の公開記事:"
  puts "  タイトル: #{first_article.title}"
  puts "  著者: #{first_article.user.name}"
  puts "  公開日: #{first_article.published_at.strftime('%Y-%m-%d')}"
  puts "  コメント数: #{first_article.comments.count}"
  puts ""
end

# 最初のグループの情報を表示
first_group = Group.first
puts "最初のグループ:"
puts "  名前: #{first_group.name}"
puts "  メンバー数: #{first_group.members_count}"
puts "  管理者数: #{first_group.admins.count}"
puts "  モデレーター数: #{first_group.moderators.count}"
puts ""

puts "=" * 80
puts "railsコンソールで以下のコマンドを試してみてください:"
puts "  User.first.articles"
puts "  Article.published.recent.limit(5)"
puts "  Group.first.users"
puts "  User.first.groups"
puts "=" * 80
