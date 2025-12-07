# frozen_string_literal: true

# ビュー機能デモ用のサンプルデータを生成するスクリプト
# rails runner seed_data.rb で実行します

puts '=' * 80
puts 'ビュー機能デモ用サンプルデータの生成'
puts '=' * 80
puts ''

# 既存のデータをクリア（開発環境でのみ実行）
if Rails.env.development?
  puts '既存のデータをクリアしています...'
  
  # 依存関係を考慮した順序で削除
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

user_data = [
  { name: 'Alice Johnson', email: 'alice@example.com' },
  { name: 'Bob Smith', email: 'bob@example.com' },
  { name: 'Carol Williams', email: 'carol@example.com' },
  { name: 'David Brown', email: 'david@example.com' },
  { name: 'Emma Davis', email: 'emma@example.com' }
]

user_data.each do |data|
  user = User.create!(data)
  users << user
  print '.'
end

puts " 完了（#{users.count}人のユーザーを作成）"
puts ''

# 記事の作成
puts '記事を作成しています...'
articles = []

article_templates = [
  {
    title: 'Getting Started with Ruby on Rails',
    content: <<~CONTENT
      Ruby on Rails is a powerful web application framework that follows the Model-View-Controller (MVC) pattern.
      
      In this article, we'll explore the basics of Rails and how to get started with your first application.
      
      Rails provides a set of conventions that make web development faster and more enjoyable. The framework
      emphasizes "Convention over Configuration" and "Don't Repeat Yourself" (DRY) principles.
      
      Key features of Rails include:
      - Active Record for database interactions
      - Action Controller for handling requests
      - Action View for rendering templates
      - Asset Pipeline for managing assets
      - Turbo and Stimulus for modern JavaScript interactions
      
      Getting started is easy. Simply install Ruby, then install Rails with `gem install rails`.
      Create a new application with `rails new myapp` and you're ready to go!
    CONTENT
  },
  {
    title: 'Understanding Turbo in Rails 7',
    content: <<~CONTENT
      Turbo is a collection of techniques for creating fast, modern web applications without writing much JavaScript.
      
      Turbo consists of three main components:
      
      1. Turbo Drive: Accelerates page navigation by intercepting link clicks and form submissions,
         fetching the new page via AJAX, and replacing the body content.
      
      2. Turbo Frames: Allow you to decompose pages into independent contexts that can be updated
         individually without a full page refresh.
      
      3. Turbo Streams: Enable you to deliver page updates over WebSocket, SSE, or in response to
         form submissions, updating multiple parts of the page at once.
      
      With Turbo, you can build highly interactive applications that feel like SPAs while maintaining
      the simplicity of server-rendered HTML.
    CONTENT
  },
  {
    title: 'Mastering Stimulus Controllers',
    content: <<~CONTENT
      Stimulus is a modest JavaScript framework designed to enhance your HTML with just enough behavior.
      
      Unlike heavy JavaScript frameworks, Stimulus doesn't try to take over your entire frontend.
      Instead, it works with the HTML you already have, adding interactivity where you need it.
      
      Key concepts in Stimulus:
      
      Controllers: JavaScript classes that connect to DOM elements
      Actions: Methods that respond to DOM events
      Targets: References to important elements within the controller's scope
      Values: Data that can be read from HTML attributes
      
      Example controller:
      
      ```javascript
      import { Controller } from "@hotwired/stimulus"
      
      export default class extends Controller {
        static targets = ["output"]
        static values = { name: String }
        
        greet() {
          this.outputTarget.textContent = `Hello, ${this.nameValue}!`
        }
      }
      ```
      
      This simple pattern keeps your JavaScript organized and maintainable.
    CONTENT
  },
  {
    title: 'Best Practices for Rails Views',
    content: <<~CONTENT
      Well-structured views are essential for maintainable Rails applications. Here are some best practices.
      
      1. Use Partials Wisely
      Extract repeated code into partials, but don't over-partition. A good rule of thumb is to
      create a partial when code is repeated more than twice.
      
      2. Keep Logic Out of Views
      Views should focus on presentation. Move complex logic to helpers, decorators, or presenters.
      
      3. Use Semantic HTML
      Proper HTML structure improves accessibility and SEO. Use appropriate tags like <article>,
      <section>, <nav>, and <aside>.
      
      4. Leverage Layout Inheritance
      Use layouts to share common structure across pages. Nested layouts can handle section-specific
      variations.
      
      5. Prefer Local Variables
      Pass data to partials as local variables rather than relying on instance variables.
      This makes dependencies explicit and improves testability.
    CONTENT
  },
  {
    title: 'Form Handling in Rails',
    content: <<~CONTENT
      Rails provides powerful form helpers that make building forms straightforward and secure.
      
      The `form_with` helper is the modern way to create forms in Rails. It automatically handles
      CSRF protection, model binding, and Turbo integration.
      
      Key features:
      
      - Automatic HTTP method detection based on model state
      - Built-in validation error handling
      - Support for nested attributes
      - Turbo integration for seamless form submissions
      
      Example:
      
      ```erb
      <%= form_with model: @article do |f| %>
        <%= f.label :title %>
        <%= f.text_field :title %>
        
        <%= f.label :content %>
        <%= f.text_area :content %>
        
        <%= f.submit %>
      <% end %>
      ```
      
      This simple code generates a complete, secure form with proper validation handling.
    CONTENT
  }
]

users.each do |user|
  # 各ユーザーに2-3個の記事を作成
  rand(2..3).times do |i|
    template = article_templates.sample
    published = [true, false].sample
    
    article = user.articles.create!(
      title: "#{template[:title]} - Part #{i + 1}",
      content: template[:content],
      published: published,
      published_at: published ? rand(1..30).days.ago : nil
    )
    articles << article
    print '.'
  end
end

puts " 完了（#{articles.count}個の記事を作成）"
puts ''

# コメントの作成
puts 'コメントを作成しています...'
comment_count = 0

comment_templates = [
  'Great article! Very helpful.',
  'Thanks for sharing this information.',
  'I learned a lot from this post.',
  'Could you explain more about this topic?',
  'This is exactly what I was looking for.',
  'Well written and easy to understand.',
  'I have a question about the implementation.',
  'This helped me solve my problem!',
  'Looking forward to more articles like this.',
  'Excellent explanation of the concepts.'
]

articles.each do |article|
  # 各記事に0-5個のコメントを追加
  rand(0..5).times do
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

puts " 完了（#{comment_count}個のコメントを作成）"
puts ''

# 結果のサマリーを表示
puts '=' * 80
puts 'サンプルデータの生成が完了しました'
puts '=' * 80
puts ''

puts '生成されたデータ:'
puts "  ユーザー数: #{User.count}"
puts "  記事数: #{Article.count}"
puts "    - 公開済み: #{Article.where(published: true).count}"
puts "    - 下書き: #{Article.where(published: false).count}"
puts "  コメント数: #{Comment.count}"
puts ''

# サンプルクエリを実行
puts 'サンプルデータ:'
puts '-' * 40
puts ''

first_user = User.first
if first_user
  puts "最初のユーザー:"
  puts "  名前: #{first_user.name}"
  puts "  メール: #{first_user.email}"
  puts "  記事数: #{first_user.articles.count}"
  puts ''
end

first_article = Article.where(published: true).first
if first_article
  puts "最初の公開記事:"
  puts "  タイトル: #{first_article.title}"
  puts "  著者: #{first_article.user.name}"
  puts "  コメント数: #{first_article.comments.count}"
  puts "  公開日: #{first_article.published_at&.strftime('%Y-%m-%d')}"
  puts ''
end

puts '=' * 80
puts 'ビューのテスト方法:'
puts '  1. rails server でサーバーを起動'
puts '  2. http://localhost:3000/articles にアクセス'
puts '  3. 記事の一覧、詳細、作成、編集を確認'
puts '=' * 80

