# frozen_string_literal: true

# Commentモデル
# 記事に対するコメントを管理するモデルです。

class Comment < ApplicationRecord
  # 関連付け
  # コメントは1人のユーザーに属します
  belongs_to :user
  
  # コメントは1つの記事に属します
  belongs_to :article

  # バリデーション
  # 本文は必須で、2文字以上1000文字以内
  validates :content, presence: true, length: { minimum: 2, maximum: 1000 }

  # スコープ
  # 新しい順に並べ替え
  scope :recent, -> { order(created_at: :desc) }
  
  # 古い順に並べ替え
  scope :oldest, -> { order(created_at: :asc) }
  
  # 特定のユーザーのコメントを取得
  scope :by_user, ->(user) { where(user: user) }
  
  # 特定の記事のコメントを取得
  scope :for_article, ->(article) { where(article: article) }

  # クラスメソッド
  # 今日のコメントを取得
  def self.today
    where('created_at >= ?', Time.current.beginning_of_day)
  end

  # 今週のコメントを取得
  def self.this_week
    where('created_at >= ?', Time.current.beginning_of_week)
  end

  # インスタンスメソッド
  # コメントの要約を取得（最初の50文字）
  def summary(length = 50)
    content.truncate(length)
  end
end
