# frozen_string_literal: true

# デバッグ技法のデモンストレーション
# rails runner debugging_demo.rb で実行します

puts '=' * 80
puts 'デバッグ技法のデモンストレーション'
puts '=' * 80
puts ''

puts '1. byebugの使用'
puts '-' * 40
puts ''

byebug_usage = <<~RUBY
# デバッガの設置
def calculate_total(items)
  subtotal = items.sum(&:price)
  byebug  # ここで実行が停止
  tax = subtotal * 0.1
  subtotal + tax
end

# 条件付きブレークポイント
def process_items(items)
  items.each do |item|
    byebug if item.price > 1000  # 高額商品のみでデバッグ
    process(item)
  end
end

# byebugコマンド一覧:
# next (n)      - 次の行に進む
# step (s)      - メソッドの中に入る
# continue (c)  - 次のブレークポイントまで実行
# finish (f)    - 現在のフレームを抜ける
# list (l)      - 現在の行周辺のコードを表示
# var local     - ローカル変数を表示
# var instance  - インスタンス変数を表示
# where (w)     - スタックトレースを表示
# up            - 上のフレームに移動
# down          - 下のフレームに移動
# quit (q)      - デバッガを終了
RUBY

puts byebug_usage
puts ''

puts '2. debug gem（Ruby 3.1+）'
puts '-' * 40
puts ''

debug_gem = <<~RUBY
# Gemfile
gem 'debug', group: [:development, :test]

# 使用方法
def calculate_total(items)
  subtotal = items.sum(&:price)
  binding.break  # または debugger
  tax = subtotal * 0.1
  subtotal + tax
end

# リモートデバッグ
# RUBY_DEBUG_OPEN=true rails server

# debug gemコマンド:
# n, next       - 次の行に進む
# s, step       - メソッドの中に入る
# c, continue   - 続行
# finish        - 現在のフレームを抜ける
# b, break      - ブレークポイントを設定
# info          - 情報を表示
# p, pp         - 式を評価して表示
# e, eval       - 式を評価
# q, quit       - 終了
RUBY

puts debug_gem
puts ''

puts '3. pryの使用'
puts '-' * 40
puts ''

pry_usage = <<~RUBY
# Gemfile
gem 'pry-rails', group: [:development, :test]
gem 'pry-byebug', group: [:development, :test]

# 使用方法
def calculate_total(items)
  subtotal = items.sum(&:price)
  binding.pry  # ここで実行が停止
  tax = subtotal * 0.1
  subtotal + tax
end

# pryコマンド:
# ls            - 利用可能なメソッドを表示
# cd            - コンテキストを変更
# show-source   - ソースコードを表示
# show-doc      - ドキュメントを表示
# whereami      - 現在の位置を表示
# edit          - エディタで編集
# !             - シェルコマンドを実行
RUBY

puts pry_usage
puts ''

puts '4. ログを使ったデバッグ'
puts '-' * 40
puts ''

logging = <<~RUBY
# コントローラでのログ出力
class ArticlesController < ApplicationController
  def create
    Rails.logger.debug "Creating article with params: \#{params.inspect}"
    
    @article = Article.new(article_params)
    
    if @article.save
      Rails.logger.info "Article created: \#{@article.id}"
      redirect_to @article
    else
      Rails.logger.warn "Article creation failed: \#{@article.errors.full_messages}"
      render :new
    end
  rescue => e
    Rails.logger.error "Error creating article: \#{e.message}"
    Rails.logger.error e.backtrace.join("\\n")
    raise
  end
end

# モデルでのログ出力
class Article < ApplicationRecord
  after_save :log_save

  private

  def log_save
    Rails.logger.info "Article \#{id} saved by user \#{user_id}"
  end
end

# ログレベル:
# Rails.logger.debug   - 詳細なデバッグ情報
# Rails.logger.info    - 一般的な情報
# Rails.logger.warn    - 警告
# Rails.logger.error   - エラー
# Rails.logger.fatal   - 致命的なエラー

# タグ付きログ
Rails.logger.tagged('ArticleService', 'create') do
  Rails.logger.info "Processing article creation"
end
RUBY

puts logging
puts ''

puts '5. Rails Console でのデバッグ'
puts '-' * 40
puts ''

console = <<~RUBY
# Rails Console の起動
# rails console

# サンドボックスモード（変更がロールバックされる）
# rails console --sandbox

# 便利なコマンド
> reload!                    # コードをリロード
> app.get '/articles'        # HTTPリクエストをシミュレート
> helper.number_to_currency(100)  # ヘルパーメソッドを呼び出し

# オブジェクトの調査
> article = Article.first
> article.methods.grep(/publish/)  # publishを含むメソッドを検索
> article.attributes               # 属性をハッシュで取得
> article.changes                  # 変更を確認

# SQLの確認
> Article.where(published: true).to_sql
> Article.includes(:comments).to_sql

# ActiveRecordのログを有効化
> ActiveRecord::Base.logger = Logger.new(STDOUT)
RUBY

puts console
puts ''

puts '6. エラーハンドリングとデバッグ'
puts '-' * 40
puts ''

error_handling = <<~RUBY
# 詳細なエラー情報の取得
begin
  risky_operation
rescue => e
  puts "Error: \#{e.message}"
  puts "Class: \#{e.class}"
  puts "Backtrace:"
  puts e.backtrace.first(10).join("\\n")
  
  # 原因の確認（Ruby 2.1+）
  if e.cause
    puts "Caused by: \#{e.cause.message}"
  end
end

# カスタム例外でのデバッグ情報
class ArticleError < StandardError
  attr_reader :article, :context

  def initialize(message, article: nil, context: {})
    @article = article
    @context = context
    super(message)
  end
end

# 使用例
raise ArticleError.new(
  "Failed to publish article",
  article: article,
  context: { user_id: current_user.id, action: 'publish' }
)
RUBY

puts error_handling
puts ''

puts '7. テストでのデバッグ'
puts '-' * 40
puts ''

test_debugging = <<~RUBY
# RSpecでのデバッグ
RSpec.describe Article, type: :model do
  it 'publishes the article' do
    article = create(:article)
    
    # デバッガを設置
    byebug
    
    article.publish!
    
    # 期待値の確認
    expect(article.published).to be true
  end
end

# 失敗したテストの詳細を表示
# bundle exec rspec --format documentation

# 特定のテストのみ実行
# bundle exec rspec spec/models/article_spec.rb:10

# 失敗時に停止
# bundle exec rspec --fail-fast

# シードを指定して再現
# bundle exec rspec --seed 12345

# save_and_open_page（Capybara）
RSpec.describe 'Articles', type: :system do
  it 'shows the article' do
    visit article_path(article)
    save_and_open_page  # ブラウザでページを開く
    expect(page).to have_content(article.title)
  end
end
RUBY

puts test_debugging
puts ''

puts '=' * 80
puts 'デバッグのベストプラクティス'
puts '=' * 80
puts ''

puts '1. 問題を再現する最小のコードを見つける'
puts '2. 仮説を立てて検証する'
puts '3. 一度に一つの変更を試す'
puts '4. ログを活用して実行フローを追跡'
puts '5. テストを書いて問題を固定化'
puts ''

puts '=' * 80

