# frozen_string_literal: true

# デプロイ・運用機能デモ用のサンプルデータを生成するスクリプト
# rails runner seed_data.rb で実行します

puts '=' * 80
puts 'デプロイ・運用機能デモ用サンプルデータの生成'
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

5.times do |i|
  user = User.create!(
    name: "Deploy User #{i + 1}",
    email: "deploy#{i + 1}@example.com",
    password: 'password123',
    password_confirmation: 'password123',
    role: i == 0 ? :admin : :member
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
  3.times do |i|
    article = user.articles.create!(
      title: "Deployment Article #{i + 1} by #{user.name}",
      content: "This is deployment related content. " * 10,
      published: [true, true, false].sample,
      published_at: [true, true, false].sample ? rand(1..30).days.ago : nil
    )
    articles << article
    print '.'
  end
end

puts ''
puts "  完了（#{articles.count}個の記事を作成）"
puts ''

# 結果のサマリーを表示
puts '=' * 80
puts 'サンプルデータの生成が完了しました'
puts '=' * 80
puts ''

puts '生成されたデータ:'
puts "  ユーザー数: #{User.count}"
puts "  記事数: #{Article.count}"
puts ''

puts '=' * 80

