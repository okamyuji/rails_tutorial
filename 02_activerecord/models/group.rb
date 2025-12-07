# frozen_string_literal: true

# Groupモデル
# ユーザーグループを管理するモデルです。
# ユーザーは複数のグループに所属できます。

class Group < ApplicationRecord
  # 関連付け
  # has_many :through で多対多の関連を表現します
  # グループは中間テーブル(Membership)を経由して複数のユーザーを持ちます
  has_many :memberships, dependent: :destroy
  has_many :users, through: :memberships

  # バリデーション
  # グループ名は必須で、3文字以上100文字以内、ユニーク
  validates :name, presence: true, 
                   length: { minimum: 3, maximum: 100 },
                   uniqueness: true
  
  # 説明は任意だが、設定する場合は10文字以上
  validates :description, length: { minimum: 10 }, allow_blank: true

  # スコープ
  # 新しい順に並べ替え
  scope :recent, -> { order(created_at: :desc) }
  
  # グループ名で検索
  scope :search_by_name, ->(query) {
    where('name LIKE ?', "%#{query}%") if query.present?
  }

  # クラスメソッド
  # メンバー数が多い順に取得
  def self.popular(limit = 10)
    left_joins(:memberships)
      .group(:id)
      .order('COUNT(memberships.id) DESC')
      .limit(limit)
  end

  # インスタンスメソッド
  # グループのメンバー数を取得
  def members_count
    users.count
  end

  # 特定のユーザーがメンバーかどうかを確認
  def has_member?(user)
    users.include?(user)
  end

  # グループの管理者を取得
  def admins
    users.joins(:memberships).where(memberships: { role: :admin })
  end

  # グループのモデレーターを取得
  def moderators
    users.joins(:memberships).where(memberships: { role: :moderator })
  end

  # 通常メンバーを取得
  def regular_members
    users.joins(:memberships).where(memberships: { role: :member })
  end
end
