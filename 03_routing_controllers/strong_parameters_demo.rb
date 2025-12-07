# frozen_string_literal: true

# Strong Parametersのデモンストレーション
# rails runner strong_parameters_demo.rb で実行します

puts "=" * 80
puts "Strong Parametersのデモンストレーション"
puts "=" * 80
puts ""

# ActionController::Parametersをシミュレート
params_hash = {
  article: {
    title: "Test Article",
    content: "This is the content",
    published: true,
    admin_only: true,  # 許可されていないパラメータ
    user_id: 1
  }
}

params = ActionController::Parameters.new(params_hash)

puts "デモ1: 基本的なStrong Parameters"
puts "-" * 40
puts ""

puts "元のパラメータ:"
puts params.inspect
puts ""

puts "許可するパラメータを指定:"
permitted_params = params.require(:article).permit(:title, :content, :published, :user_id)
puts permitted_params.inspect
puts ""

puts "結果:"
puts "  title: #{permitted_params[:title]}"
puts "  content: #{permitted_params[:content]}"
puts "  published: #{permitted_params[:published]}"
puts "  user_id: #{permitted_params[:user_id]}"
puts "  admin_only: #{permitted_params[:admin_only] || '(除外されました)'}"
puts ""

puts "=" * 80
puts "デモ2: ネストした属性の許可"
puts "-" * 40
puts ""

nested_params_hash = {
  article: {
    title: "Article with Tags",
    content: "Content here",
    tag_ids: [1, 2, 3],
    metadata: {
      author: "John Doe",
      source: "Example",
      views: 100
    }
  }
}

nested_params = ActionController::Parameters.new(nested_params_hash)

puts "元のパラメータ:"
puts nested_params.inspect
puts ""

puts "配列とハッシュを含むパラメータを許可:"
permitted_nested = nested_params.require(:article).permit(
  :title,
  :content,
  tag_ids: [],
  metadata: [:author, :source]
)

puts permitted_nested.inspect
puts ""

puts "結果:"
puts "  title: #{permitted_nested[:title]}"
puts "  tag_ids: #{permitted_nested[:tag_ids]}"
puts "  metadata[:author]: #{permitted_nested[:metadata][:author]}"
puts "  metadata[:source]: #{permitted_nested[:metadata][:source]}"
puts "  metadata[:views]: #{permitted_nested[:metadata][:views] || '(除外されました)'}"
puts ""

puts "=" * 80
puts "デモ3: 条件付きパラメータの許可"
puts "-" * 40
puts ""

# ユーザーの役割をシミュレート
class CurrentUser
  attr_accessor :admin
  
  def initialize(admin: false)
    @admin = admin
  end
  
  def admin?
    @admin
  end
end

def article_params(params, current_user)
  permitted = [:title, :content, :user_id]
  
  # 管理者のみが公開ステータスを変更できる
  permitted << :published if current_user.admin?
  
  params.require(:article).permit(*permitted)
end

# 一般ユーザーの場合
regular_user = CurrentUser.new(admin: false)
regular_params = ActionController::Parameters.new(params_hash)
regular_permitted = article_params(regular_params, regular_user)

puts "一般ユーザーが許可されるパラメータ:"
puts regular_permitted.inspect
puts "  published: #{regular_permitted[:published] || '(除外されました)'}"
puts ""

# 管理者の場合
admin_user = CurrentUser.new(admin: true)
admin_params = ActionController::Parameters.new(params_hash)
admin_permitted = article_params(admin_params, admin_user)

puts "管理者が許可されるパラメータ:"
puts admin_permitted.inspect
puts "  published: #{admin_permitted[:published]}"
puts ""

puts "=" * 80
puts "デモ4: セキュリティリスクの例"
puts "-" * 40
puts ""

dangerous_params_hash = {
  user: {
    name: "Alice",
    email: "alice@example.com",
    admin: true,  # 攻撃者が管理者権限を取得しようとする
    role: "admin"
  }
}

puts "攻撃者が送信するパラメータ:"
puts dangerous_params_hash.inspect
puts ""

dangerous_params = ActionController::Parameters.new(dangerous_params_hash)

puts "Strong Parametersなしの場合（危険）:"
puts "  User.new(params[:user])"
puts "  → すべてのパラメータが渡される"
puts "  → 攻撃者がadmin権限を取得できる！"
puts ""

puts "Strong Parametersを使用した場合（安全）:"
safe_params = dangerous_params.require(:user).permit(:name, :email)
puts safe_params.inspect
puts "  → adminとroleパラメータは除外される"
puts "  → セキュリティリスクが軽減される"
puts ""

puts "=" * 80
puts "デモ5: 実践的なパターン"
puts "-" * 40
puts ""

puts "1. 複数のパラメータセットを使用:"
puts ""
puts "# 作成時のパラメータ"
puts "def create_params"
puts "  params.require(:article).permit(:title, :content, :user_id)"
puts "end"
puts ""
puts "# 更新時のパラメータ（user_idは変更不可）"
puts "def update_params"
puts "  params.require(:article).permit(:title, :content, :published)"
puts "end"
puts ""

puts "2. accepts_nested_attributes_forとの組み合わせ:"
puts ""
puts "# モデル"
puts "class Article < ApplicationRecord"
puts "  has_many :images"
puts "  accepts_nested_attributes_for :images, allow_destroy: true"
puts "end"
puts ""
puts "# コントローラ"
puts "def article_params"
puts "  params.require(:article).permit("
puts "    :title,"
puts "    :content,"
puts "    images_attributes: [:id, :url, :caption, :_destroy]"
puts "  )"
puts "end"
puts ""

puts "3. 任意のキーを持つハッシュを許可:"
puts ""
puts "# すべてのキーを許可（慎重に使用）"
puts "def article_params"
puts "  params.require(:article).permit(:title, :content, metadata: {})"
puts "end"
puts ""

puts "=" * 80
puts "まとめ"
puts "=" * 80
puts ""

puts "Strong Parametersの目的:"
puts "  マスアサインメント脆弱性を防ぐ"
puts "  明示的に許可したパラメータのみを受け取る"
puts ""

puts "基本的な使い方:"
puts "  require: 必須のキーを指定"
puts "  permit: 許可するパラメータを指定"
puts ""

puts "高度な使い方:"
puts "  配列パラメータ: param_name: []"
puts "  ハッシュパラメータ: param_name: [:key1, :key2]"
puts "  ネストした属性: model_attributes: [:id, :field, :_destroy]"
puts ""

puts "ベストプラクティス:"
puts "  - 最小限のパラメータのみを許可"
puts "  - 役割に応じて異なるパラメータセットを使用"
puts "  - 条件付き許可を適切に実装"
puts "  - セキュリティを最優先に考える"
puts ""

puts "=" * 80
