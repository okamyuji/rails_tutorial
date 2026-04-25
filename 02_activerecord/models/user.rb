# frozen_string_literal: true

# Userモデル
# ユーザー情報を管理するモデルです。
# 記事の投稿、コメント、グループへの参加などの機能を持ちます。

class User < ApplicationRecord
  # 関連付け
  # has_many は 1対多の関連を表現します
  # ユーザーは複数の記事を持つことができます
  has_many :articles, dependent: :destroy

  # ユーザーは複数のコメントを投稿できます
  has_many :comments, dependent: :destroy

  # has_many :through で多対多の関連を表現します
  # ユーザーは中間テーブル(Membership)を経由して複数のグループに所属できます
  has_many :memberships, dependent: :destroy
  has_many :groups, through: :memberships

  # バリデーション
  # 名前は必須で、2文字以上50文字以内
  validates :name, presence: true, length: { minimum: 2, maximum: 50 }

  # メールアドレスは必須で、形式チェックとユニーク制約を設定
  validates :email,
            presence: true,
            format: {
              with: URI::MailTo::EMAIL_REGEXP
            },
            uniqueness: {
              case_sensitive: false
            }

  # 年齢は0以上150以下の範囲で許可（任意項目）
  validates :age,
            numericality: {
              only_integer: true,
              greater_than_or_equal_to: 0,
              less_than_or_equal_to: 150
            },
            allow_nil: true

  # コールバック
  # 保存前にメールアドレスを正規化（小文字化、空白削除）
  before_save :normalize_email

  # スコープ
  # よく使用するクエリをスコープとして定義します
  scope :adult, -> { where("age >= ?", 18) }
  scope :recent, -> { order(created_at: :desc) }
  scope :with_email, -> { where.not(email: nil) }

  # クラスメソッド
  # 特定の期間に作成されたユーザーを取得
  def self.created_in_month(date)
    start_date = date.beginning_of_month
    end_date = date.end_of_month
    where(created_at: start_date..end_date)
  end

  # 検索メソッド
  def self.search(query)
    return none if query.blank?

    where("name LIKE ? OR email LIKE ?", "%#{query}%", "%#{query}%")
  end

  # インスタンスメソッド
  # ユーザーの公開済み記事を取得
  def published_articles
    articles.published
  end

  # ユーザーがグループのメンバーかどうかを確認
  def member_of?(group)
    groups.include?(group)
  end

  # ユーザーがグループの管理者かどうかを確認
  def admin_of?(group)
    memberships.find_by(group: group)&.admin?
  end

  private

  # メールアドレスを正規化（小文字化、前後の空白を削除）
  def normalize_email
    self.email = email.downcase.strip if email.present?
  end
end
