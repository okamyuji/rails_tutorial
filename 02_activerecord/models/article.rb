# frozen_string_literal: true

# Articleモデル
# ブログ記事を管理するモデルです。
# ユーザーが作成し、複数のコメントを持つことができます。

class Article < ApplicationRecord
  # 関連付け
  # 記事は1人のユーザーに属します
  belongs_to :user

  # 記事は複数のコメントを持ちます
  # dependent: :destroy により、記事を削除すると関連コメントも削除されます
  has_many :comments, dependent: :destroy

  # バリデーション
  # タイトルは必須で、5文字以上200文字以内
  validates :title, presence: true, length: { minimum: 5, maximum: 200 }

  # 本文は必須で、最小10文字
  validates :content, presence: true, length: { minimum: 10 }

  # 公開日時は、公開済みの場合は必須
  validates :published_at, presence: true, if: :published?

  # カスタムバリデーション
  validate :published_at_cannot_be_in_the_past, if: :published?

  # スコープ
  # 公開済みの記事のみを取得
  scope :published, -> { where(published: true) }

  # 下書きの記事のみを取得
  scope :draft, -> { where(published: false) }

  # 新しい順に並べ替え
  scope :recent, -> { order(created_at: :desc) }

  # 古い順に並べ替え
  scope :oldest, -> { order(created_at: :asc) }

  # 特定のユーザーの記事を取得
  scope :by_user, ->(user) { where(user: user) }

  # 特定の期間に公開された記事を取得
  scope :published_between,
        lambda { |start_date, end_date|
          where(published_at: start_date..end_date)
        }

  # クラスメソッド
  # 今月公開された記事を取得
  def self.published_this_month
    start_date = Time.current.beginning_of_month
    end_date = Time.current.end_of_month
    published.where(published_at: start_date..end_date)
  end

  # タイトルまたは本文で検索
  def self.search(query)
    return none if query.blank?

    where("title LIKE ? OR content LIKE ?", "%#{query}%", "%#{query}%")
  end

  # 人気の記事（コメント数が多い順）
  def self.popular(limit = 10)
    left_joins(:comments)
      .group(:id)
      .order("COUNT(comments.id) DESC")
      .limit(limit)
  end

  # インスタンスメソッド
  # 記事を公開する
  def publish!
    update!(published: true, published_at: Time.current)
  end

  # 記事を下書きに戻す
  def unpublish!
    update!(published: false, published_at: nil)
  end

  # 記事の要約を取得（最初の100文字）
  def summary(length = 100)
    content.truncate(length)
  end

  # 記事のコメント数を取得
  def comments_count
    comments.size
  end

  private

  # 公開日時が過去でないことを検証
  def published_at_cannot_be_in_the_past
    if published_at.present? && published_at < Time.current
      errors.add(:published_at, "cannot be in the past")
    end
  end
end
