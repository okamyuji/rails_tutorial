# frozen_string_literal: true

# Permissionモデル
# リソースベースの権限管理を実装します

class Permission < ApplicationRecord
  # 関連付け
  belongs_to :user
  belongs_to :resource, polymorphic: true

  # アクション定義
  # read: 閲覧権限
  # write: 編集権限
  # delete: 削除権限
  # admin: 管理権限（すべての操作が可能）
  enum action: { read: 0, write: 1, delete: 2, admin: 3 }

  # バリデーション
  validates :user_id, presence: true
  validates :resource_type, presence: true
  validates :resource_id, presence: true
  validates :action, presence: true
  validates :user_id,
            uniqueness: {
              scope: %i[resource_type resource_id action]
            }

  # スコープ
  scope :for_resource,
        lambda { |resource|
          where(resource_type: resource.class.name, resource_id: resource.id)
        }
  scope :for_user, ->(user) { where(user: user) }
  scope :readable, -> { where(action: %i[read write delete admin]) }
  scope :writable, -> { where(action: %i[write delete admin]) }
  scope :deletable, -> { where(action: %i[delete admin]) }

  # ユーザーがリソースに対して特定のアクションを実行できるか確認
  #
  # @param user [User] ユーザーオブジェクト
  # @param resource [ApplicationRecord] リソースオブジェクト
  # @param action [Symbol] アクション名
  # @return [Boolean]
  def self.can?(user, resource, action)
    return false unless user

    # 管理者は常に許可
    return true if user.admin?

    # 権限を確認
    actions =
      case action.to_sym
      when :read
        %i[read write delete admin]
      when :write
        %i[write delete admin]
      when :delete
        %i[delete admin]
      when :admin
        [:admin]
      else
        []
      end

    exists?(
      user: user,
      resource_type: resource.class.name,
      resource_id: resource.id,
      action: actions
    )
  end

  # ユーザーにリソースへの権限を付与
  #
  # @param user [User] ユーザーオブジェクト
  # @param resource [ApplicationRecord] リソースオブジェクト
  # @param action [Symbol] アクション名
  # @return [Permission]
  def self.grant!(user, resource, action)
    find_or_create_by!(
      user: user,
      resource_type: resource.class.name,
      resource_id: resource.id,
      action: action
    )
  end

  # ユーザーからリソースへの権限を削除
  #
  # @param user [User] ユーザーオブジェクト
  # @param resource [ApplicationRecord] リソースオブジェクト
  # @param action [Symbol] アクション名（nilの場合はすべての権限を削除）
  def self.revoke!(user, resource, action = nil)
    scope =
      where(
        user: user,
        resource_type: resource.class.name,
        resource_id: resource.id
      )
    scope = scope.where(action: action) if action
    scope.destroy_all
  end

  # リソースに対するすべての権限を削除
  #
  # @param resource [ApplicationRecord] リソースオブジェクト
  def self.revoke_all!(resource)
    where(
      resource_type: resource.class.name,
      resource_id: resource.id
    ).destroy_all
  end

  # ユーザーが持つすべての権限を取得
  #
  # @param user [User] ユーザーオブジェクト
  # @return [Hash] リソースタイプごとの権限
  def self.permissions_for(user)
    where(user: user)
      .group_by(&:resource_type)
      .transform_values do |permissions|
        permissions
          .group_by(&:resource_id)
          .transform_values { |perms| perms.map(&:action) }
      end
  end
end

# マイグレーション例:
#
# class CreatePermissions < ActiveRecord::Migration[8.0]
#   def change
#     create_table :permissions do |t|
#       t.references :user, null: false, foreign_key: true
#       t.string :resource_type, null: false
#       t.bigint :resource_id, null: false
#       t.integer :action, null: false, default: 0
#
#       t.timestamps
#     end
#
#     add_index :permissions, [:resource_type, :resource_id]
#     add_index :permissions, [:user_id, :resource_type, :resource_id, :action],
#               unique: true, name: 'index_permissions_unique'
#   end
# end
