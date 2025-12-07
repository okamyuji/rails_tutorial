# frozen_string_literal: true

# ArticlePolicy
# 記事に対する権限を定義します

class ArticlePolicy < ApplicationPolicy
  # 一覧表示
  # 誰でも閲覧可能
  def index?
    true
  end

  # 詳細表示
  # 公開記事は誰でも閲覧可能
  # 下書きは作者と管理者のみ閲覧可能
  def show?
    record.published? || owner? || admin?
  end

  # 作成
  # ログインユーザーのみ作成可能
  def create?
    logged_in?
  end

  # 更新
  # 作者または管理者のみ更新可能
  def update?
    owner? || admin?
  end

  # 削除
  # 作者または管理者のみ削除可能
  def destroy?
    owner? || admin?
  end

  # 公開
  # 作者、編集者、管理者のみ公開可能
  def publish?
    owner? || editor_or_above?
  end

  # 非公開
  # 作者、編集者、管理者のみ非公開可能
  def unpublish?
    owner? || editor_or_above?
  end

  # フィーチャー（注目記事に設定）
  # 編集者と管理者のみ設定可能
  def feature?
    editor_or_above?
  end

  # 許可される属性
  # ユーザーのロールに応じて編集可能な属性を制限
  #
  # @return [Array<Symbol>]
  def permitted_attributes
    if admin?
      # 管理者はすべての属性を編集可能
      [:title, :content, :published, :featured, :category_id, :published_at, tag_ids: []]
    elsif user&.editor?
      # 編集者は公開状態とカテゴリを編集可能
      [:title, :content, :published, :category_id, tag_ids: []]
    else
      # 一般ユーザーは基本的な属性のみ編集可能
      [:title, :content]
    end
  end

  # 作成時に許可される属性
  #
  # @return [Array<Symbol>]
  def permitted_attributes_for_create
    [:title, :content, :category_id, tag_ids: []]
  end

  # 更新時に許可される属性
  #
  # @return [Array<Symbol>]
  def permitted_attributes_for_update
    permitted_attributes
  end

  # スコープ
  # 表示可能な記事をフィルタリング
  class Scope < Scope
    def resolve
      if admin?
        # 管理者はすべての記事を表示
        scope.all
      elsif logged_in?
        # ログインユーザーは公開記事と自分の記事を表示
        scope.where(published: true)
             .or(scope.where(user: user))
      else
        # ゲストは公開記事のみ表示
        scope.where(published: true)
      end
    end

    # 公開記事のみを返すスコープ
    def published
      scope.where(published: true)
    end

    # 下書き記事のみを返すスコープ（ログインユーザー用）
    def drafts
      if admin?
        scope.where(published: false)
      elsif logged_in?
        scope.where(published: false, user: user)
      else
        scope.none
      end
    end

    # フィーチャー記事のみを返すスコープ
    def featured
      scope.where(published: true, featured: true)
    end
  end
end

