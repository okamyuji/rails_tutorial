# frozen_string_literal: true

# テスト・デバッグ機能デモ用のサンプルデータを生成するスクリプト
# rails runner seed_data.rb で実行します

puts '=' * 80
puts 'テスト・デバッグ機能デモ用サンプルデータの生成'
puts '=' * 80
puts ''

# 既存のデータをクリア（開発環境でのみ実行）
if Rails.env.development?
  puts '既存のデータをクリアしています...'

  [Comment, Article, User].each do |model|
    if model.table_exists?
      model.destroy_all
      puts "  #{model.name}: クリア完了"
    end
  end

  puts '完了'
  puts ''
end

# ユーザーの作成
puts 'ユーザーを作成しています...'
users = []

10.times do |i|
  role = case i
         when 0 then :admin
         when 1..2 then :editor
         else :member
         end

  user = User.create!(
    name: "Test User #{i + 1}",
    email: "user#{i + 1}@example.com",
    password: 'password123',
    password_confirmation: 'password123',
    role: role
  )
  user.confirm if user.respond_to?(:confirm)
  users << user
  print '.'
end

puts ''
puts "  完了（#{users.count}人のユーザーを作成）"
puts ''

# 記事の作成
puts '記事を作成しています...'
articles = []

users.each do |user|
  rand(2..5).times do |i|
    published = [true, true, true, false].sample
    article = user.articles.create!(
      title: "Article #{i + 1} by #{user.name}",
      content: "This is the content of article #{i + 1}. " * 10,
      published: published,
      published_at: published ? rand(1..30).days.ago : nil
    )
    articles << article
    print '.'
  end
end

puts ''
puts "  完了（#{articles.count}個の記事を作成）"
puts ''

# コメントの作成
puts 'コメントを作成しています...'
comment_count = 0

articles.select(&:published).each do |article|
  rand(0..5).times do
    commenter = users.sample
    Comment.create!(
      user: commenter,
      article: article,
      content: "This is a comment by #{commenter.name}."
    )
    comment_count += 1
    print '.'
  end
end

puts ''
puts "  完了（#{comment_count}個のコメントを作成）"
puts ''

# 結果のサマリーを表示
puts '=' * 80
puts 'サンプルデータの生成が完了しました'
puts '=' * 80
puts ''

puts '生成されたデータ:'
puts "  ユーザー数: #{User.count}"
puts "    - 管理者: #{User.where(role: :admin).count}"
puts "    - 編集者: #{User.where(role: :editor).count}"
puts "    - 一般: #{User.where(role: :member).count}"
puts "  記事数: #{Article.count}"
puts "    - 公開済み: #{Article.where(published: true).count}"
puts "    - 下書き: #{Article.where(published: false).count}"
puts "  コメント数: #{Comment.count}"
puts ''

puts '=' * 80
puts 'テストの実行方法:'
puts '  bundle exec rspec                    # すべてのテストを実行'
puts '  bundle exec rspec spec/models/       # モデルテストのみ'
puts '  bundle exec rspec --format doc       # ドキュメント形式で出力'
puts '=' * 80

