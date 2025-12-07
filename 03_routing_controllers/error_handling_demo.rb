# frozen_string_literal: true

# エラーハンドリングのデモンストレーション
# rails runner error_handling_demo.rb で実行します

puts "=" * 80
puts "エラーハンドリングのデモンストレーション"
puts "=" * 80
puts ""

puts "デモ1: HTTPステータスコード"
puts "-" * 40
puts ""

status_codes = {
  200 => { name: 'OK', usage: 'リクエストが成功（GET）' },
  201 => { name: 'Created', usage: 'リソースが正常に作成（POST）' },
  204 => { name: 'No Content', usage: '成功したがレスポンスボディなし（DELETE）' },
  400 => { name: 'Bad Request', usage: 'リクエストの形式が不正' },
  401 => { name: 'Unauthorized', usage: '認証が必要' },
  403 => { name: 'Forbidden', usage: '権限がない' },
  404 => { name: 'Not Found', usage: 'リソースが見つからない' },
  422 => { name: 'Unprocessable Entity', usage: 'バリデーションエラー' },
  500 => { name: 'Internal Server Error', usage: 'サーバー内部エラー' }
}

status_codes.each do |code, info|
  puts "#{code} #{info[:name].ljust(25)} → #{info[:usage]}"
end
puts ""

puts "=" * 80
puts "デモ2: JSON:API形式のエラーレスポンス"
puts "-" * 40
puts ""

puts "標準的なエラーレスポンスの形式:"
puts ""

error_response = {
  errors: [
    {
      status: '422',
      code: 'validation_failed',
      title: 'Validation Failed',
      detail: 'Title can\'t be blank',
      source: {
        pointer: '/data/attributes/title'
      }
    },
    {
      status: '422',
      code: 'validation_failed',
      title: 'Validation Failed',
      detail: 'Content is too short (minimum is 10 characters)',
      source: {
        pointer: '/data/attributes/content'
      }
    }
  ]
}

require 'json'
puts JSON.pretty_generate(error_response)
puts ""

puts "このエラーレスポンスの特徴:"
puts "  - JSON:API仕様に準拠"
puts "  - 複数のエラーを配列で返す"
puts "  - 各エラーに詳細情報を含む"
puts "  - クライアント側での処理が容易"
puts ""

puts "=" * 80
puts "デモ3: 例外のキャッチとハンドリング"
puts "-" * 40
puts ""

puts "rescue_fromの使用例:"
puts ""

rescue_from_example = <<~RUBY
class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActiveRecord::RecordInvalid, with: :record_invalid
  rescue_from ActionController::ParameterMissing, with: :parameter_missing

  private

  def record_not_found(exception)
    render json: {
      errors: [{
        status: '404',
        code: 'not_found',
        title: 'Record Not Found',
        detail: exception.message
      }]
    }, status: :not_found
  end

  def record_invalid(exception)
    render json: {
      errors: exception.record.errors.map do |error|
        {
          status: '422',
          code: 'validation_failed',
          title: 'Validation Failed',
          detail: error.full_message,
          source: { pointer: "/data/attributes/\#{error.attribute}" }
        }
      end
    }, status: :unprocessable_entity
  end

  def parameter_missing(exception)
    render json: {
      errors: [{
        status: '400',
        code: 'parameter_missing',
        title: 'Parameter Missing',
        detail: exception.message
      }]
    }, status: :bad_request
  end
end
RUBY

puts rescue_from_example
puts ""

puts "=" * 80
puts "デモ4: 実践的なエラーハンドリングパターン"
puts "-" * 40
puts ""

puts "1. コントローラでの使用例:"
puts ""

controller_example = <<~RUBY
class ArticlesController < ApplicationController
  def create
    @article = Article.new(article_params)
    @article.save!  # 失敗時に例外を発生
    
    render json: @article, status: :created
  rescue ActiveRecord::RecordInvalid => e
    # ApplicationControllerのrescue_fromが自動処理
    raise
  end
  
  def show
    @article = Article.find(params[:id])  # 見つからない場合は例外
    render json: @article
  end
end
RUBY

puts controller_example
puts ""

puts "2. カスタム例外の定義:"
puts ""

custom_exception_example = <<~RUBY
class ApplicationController < ActionController::API
  class Unauthorized < StandardError; end
  class Forbidden < StandardError; end

  rescue_from Unauthorized, with: :handle_unauthorized
  rescue_from Forbidden, with: :handle_forbidden

  private

  def handle_unauthorized
    render json: {
      errors: [{
        status: '401',
        code: 'unauthorized',
        title: 'Unauthorized',
        detail: 'Authentication required'
      }]
    }, status: :unauthorized
  end

  def handle_forbidden
    render json: {
      errors: [{
        status: '403',
        code: 'forbidden',
        title: 'Forbidden',
        detail: 'You do not have permission'
      }]
    }, status: :forbidden
  end
end
RUBY

puts custom_exception_example
puts ""

puts "3. 環境別のエラーハンドリング:"
puts ""

env_specific_example = <<~RUBY
def internal_server_error(exception)
  if Rails.env.production?
    # 本番環境: 詳細を隠す
    render json: {
      errors: [{
        status: '500',
        title: 'Internal Server Error',
        detail: 'An unexpected error occurred'
      }]
    }, status: :internal_server_error
  else
    # 開発環境: 詳細を表示
    render json: {
      errors: [{
        status: '500',
        title: 'Internal Server Error',
        detail: exception.message,
        backtrace: exception.backtrace.first(10)
      }]
    }, status: :internal_server_error
  end
end
RUBY

puts env_specific_example
puts ""

puts "=" * 80
puts "デモ5: エラーレスポンスの設計原則"
puts "-" * 40
puts ""

puts "1. 一貫性:"
puts "   すべてのエンドポイントで同じエラー形式を使用"
puts "   クライアント側での処理が容易になる"
puts ""

puts "2. 詳細な情報:"
puts "   エラーの原因を明確に伝える"
puts "   どのフィールドでエラーが発生したかを示す"
puts "   source.pointerでエラー箇所を特定"
puts ""

puts "3. 適切なステータスコード:"
puts "   HTTPステータスコードを正しく使用"
puts "   エラーの種類を明確にする"
puts ""

puts "4. セキュリティ:"
puts "   本番環境では機密情報を含めない"
puts "   スタックトレースは開発環境でのみ表示"
puts "   データベースの詳細は隠す"
puts ""

puts "5. 国際化:"
puts "   エラーメッセージを多言語化"
puts "   codeフィールドでエラーの種類を識別"
puts "   クライアント側で適切なメッセージを表示"
puts ""

puts "=" * 80
puts "デモ6: バリデーションエラーの変換"
puts "-" * 40
puts ""

# ActiveModelエラーをシミュレート
class DemoArticle
  include ActiveModel::Model
  attr_accessor :title, :content
  
  validates :title, presence: true, length: { minimum: 5 }
  validates :content, presence: true, length: { minimum: 10 }
end

article = DemoArticle.new(title: "Hi", content: "")
article.valid?

puts "ActiveModelのエラー:"
puts article.errors.full_messages.inspect
puts ""

# JSON:API形式に変換
json_api_errors = article.errors.map do |error|
  {
    status: '422',
    code: 'validation_failed',
    title: 'Validation Failed',
    detail: error.full_message,
    source: { pointer: "/data/attributes/#{error.attribute}" }
  }
end

puts "JSON:API形式のエラー:"
puts JSON.pretty_generate({ errors: json_api_errors })
puts ""

puts "=" * 80
puts "まとめ"
puts "=" * 80
puts ""

puts "エラーハンドリングの重要性:"
puts "  - ユーザーフレンドリーなエラーメッセージ"
puts "  - クライアント側での適切なエラー処理"
puts "  - デバッグの容易さ"
puts "  - セキュリティの確保"
puts ""

puts "実装のポイント:"
puts "  - rescue_fromで例外を一箇所で処理"
puts "  - 適切なHTTPステータスコードを使用"
puts "  - JSON:API形式で統一されたレスポンス"
puts "  - 環境に応じたエラー情報の出し分け"
puts ""

puts "ベストプラクティス:"
puts "  - 一貫性のあるエラー形式"
puts "  - 詳細で分かりやすいエラーメッセージ"
puts "  - 本番環境では機密情報を隠す"
puts "  - ログに詳細情報を記録"
puts ""

puts "=" * 80
