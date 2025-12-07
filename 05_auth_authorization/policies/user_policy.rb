# frozen_string_literal: true

# UserPolicy
# ユーザーに対する権限を定義します

class UserPolicy < ApplicationPolicy
  # 一覧表示
  # 管理者のみ閲覧可能
  def index?
    admin?
  end

  # 詳細表示
  # 自分自身または管理者のみ閲覧可能
  def show?
    owner_self? || admin?
  end

  # 作成（管理者によるユーザー作成）
  # 管理者のみ作成可能
  def create?
    admin?
  end

  # 更新
  # 自分自身または管理者のみ更新可能
  def update?
    owner_self? || admin?
  end

  # 削除
  # 管理者のみ削除可能（自分自身は削除不可）
  def destroy?
    admin? && !owner_self?
  end

  # ロールの変更
  # 管理者のみ変更可能（自分自身のロールは変更不可）
  def change_role?
    admin? && !owner_self?
  end

  # アカウントのロック
  # 管理者のみロック可能
  def lock?
    admin? && !owner_self?
  end

  # アカウントのロック解除
  # 管理者のみ解除可能
  def unlock?
    admin?
  end

  # パスワードのリセット
  # 自分自身または管理者のみリセット可能
  def reset_password?
    owner_self? || admin?
  end

  # 許可される属性
  #
  # @return [Array<Symbol>]
  def permitted_attributes
    if admin?
      # 管理者はすべての属性を編集可能
      [:name, :email, :password, :password_confirmation, :role, :avatar]
    else
      # 一般ユーザーは基本的な属性のみ編集可能
      [:name, :email, :password, :password_confirmation, :avatar]
    end
  end

  # 作成時に許可される属性
  #
  # @return [Array<Symbol>]
  def permitted_attributes_for_create
    if admin?
      [:name, :email, :password, :password_confirmation, :role]
    else
      [:name, :email, :password, :password_confirmation]
    end
  end

  # スコープ
  class Scope < Scope
    def resolve
      if admin?
        # 管理者はすべてのユーザーを表示
        scope.all
      else
        # 一般ユーザーは自分自身のみ表示
        scope.where(id: user&.id)
      end
    end

    # アクティブなユーザーのみを返すスコープ
    def active
      if admin?
        scope.where.not(confirmed_at: nil).where(locked_at: nil)
      else
        scope.none
      end
    end

    # ロックされたユーザーを返すスコープ（管理者用）
    def locked
      if admin?
        scope.where.not(locked_at: nil)
      else
        scope.none
      end
    end
  end

  private

  # 対象が自分自身かどうかを確認
  def owner_self?
    logged_in? && record == user
  end
end

