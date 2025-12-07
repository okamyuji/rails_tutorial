# frozen_string_literal: true

# 認証・認可機能デモ用のサンプルデータを生成するスクリプト
# rails runner seed_data.rb で実行します

puts '=' * 80
puts '認証・認可機能デモ用サンプルデータの生成'
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

# 管理者ユーザー
admin = User.create!(
  name: 'Admin User',
  email: 'admin@example.com',
  password: 'password123',
  password_confirmation: 'password123',
  role: :admin
)
admin.confirm if admin.respond_to?(:confirm)
users << admin
puts '  Admin User (admin@example.com) を作成'

# 編集者ユーザー
editor = User.create!(
  name: 'Editor User',
  email: 'editor@example.com',
  password: 'password123',
  password_confirmation: 'password123',
  role: :editor
)
editor.confirm if editor.respond_to?(:confirm)
users << editor
puts '  Editor User (editor@example.com) を作成'

# 一般ユーザー
5.times do |i|
  user = User.create!(
    name: "Member User #{i + 1}",
    email: "member#{i + 1}@example.com",
    password: 'password123',
    password_confirmation: 'password123',
    role: :member
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

article_data = [
  {
    title: 'Getting Started with Rails Authentication',
    content: 'This article explains how to implement user authentication in Rails using Devise...',
    published: true
  },
  {
    title: 'Understanding Pundit for Authorization',
    content: 'Pundit provides a simple way to organize authorization logic in your Rails application...',
    published: true
  },
  {
    title: 'Secure Session Management in Rails',
    content: 'Learn how to properly manage sessions and cookies in your Rails application...',
    published: true
  },
  {
    title: 'OAuth Integration with OmniAuth',
    content: 'This guide shows how to integrate Google, Facebook, and GitHub authentication...',
    published: true
  },
  {
    title: 'Draft: Advanced Security Topics',
    content: 'This is a draft article about advanced security topics...',
    published: false
  }
]

users.each do |user|
  article_data.sample(rand(1..3)).each do |data|
    article = user.articles.create!(
      title: "#{data[:title]} by #{user.name}",
      content: data[:content] * 3,
      published: data[:published],
      published_at: data[:published] ? rand(1..30).days.ago : nil
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

comment_templates = [
  'Great article! Very helpful for understanding authentication.',
  'Thanks for explaining the security concepts.',
  'I have a question about the authorization flow.',
  'This helped me implement Devise in my project.',
  'Clear explanation of Pundit policies.'
]

articles.select(&:published).each do |article|
  rand(0..3).times do
    commenter = users.sample

    Comment.create!(
      user: commenter,
      article: article,
      content: comment_templates.sample
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

puts 'テスト用アカウント:'
puts '  管理者: admin@example.com / password123'
puts '  編集者: editor@example.com / password123'
puts '  一般: member1@example.com / password123'
puts ''

puts '=' * 80
puts '権限テストの方法:'
puts '  1. 管理者でログイン → すべての記事を編集・削除可能'
puts '  2. 編集者でログイン → 公開記事を編集可能'
puts '  3. 一般ユーザーでログイン → 自分の記事のみ編集可能'
puts '  4. 未ログイン → 公開記事のみ閲覧可能'
puts '=' * 80

