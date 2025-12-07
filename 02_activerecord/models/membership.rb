# frozen_string_literal: true

# Membershipモデル
# ユーザーとグループの中間テーブルです。
# ユーザーのグループ内での役割（権限）を管理します。

class Membership < ApplicationRecord
  # 関連付け
  # メンバーシップは1人のユーザーに属します
  belongs_to :user
  
  # メンバーシップは1つのグループに属します
  belongs_to :group

  # Enumで役割を定義
  # member: 通常メンバー、moderator: モデレーター、admin: 管理者
  enum role: { member: 0, moderator: 1, admin: 2 }

  # バリデーション
  # 同じユーザーが同じグループに複数回参加できないようにする
  validates :user_id, uniqueness: { scope: :group_id, 
                                     message: 'is already a member of this group' }
  
  # 役割は必須
  validates :role, presence: true

  # スコープ
  # 管理者のみを取得
  scope :admins, -> { where(role: :admin) }
  
  # モデレーターのみを取得
  scope :moderators, -> { where(role: :moderator) }
  
  # 通常メンバーのみを取得
  scope :members, -> { where(role: :member) }
  
  # 新しい順に並べ替え
  scope :recent, -> { order(created_at: :desc) }

  # クラスメソッド
  # 特定のグループのメンバーシップを取得
  def self.for_group(group)
    where(group: group)
  end

  # 特定のユーザーのメンバーシップを取得
  def self.for_user(user)
    where(user: user)
  end

  # インスタンスメソッド
  # メンバーを管理者に昇格
  def promote_to_admin!
    update!(role: :admin)
  end

  # メンバーをモデレーターに昇格
  def promote_to_moderator!
    update!(role: :moderator)
  end

  # メンバーを通常メンバーに降格
  def demote_to_member!
    update!(role: :member)
  end

  # 権限レベルの文字列表現
  def role_name
    I18n.t("activerecord.attributes.membership.roles.#{role}")
  rescue
    role.humanize
  end
end
