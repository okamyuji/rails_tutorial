# frozen_string_literal: true

# CommentPolicy
# コメントに対する権限を定義します

class CommentPolicy < ApplicationPolicy
  # 一覧表示
  # 誰でも閲覧可能
  def index?
    true
  end

  # 詳細表示
  # 誰でも閲覧可能
  def show?
    true
  end

  # 作成
  # ログインユーザーのみ作成可能
  def create?
    logged_in?
  end

  # 更新
  # コメントの作者または管理者のみ更新可能
  def update?
    owner? || admin?
  end

  # 削除
  # コメントの作者、記事の作者、または管理者のみ削除可能
  def destroy?
    owner? || article_owner? || admin?
  end

  # 承認（モデレーション機能がある場合）
  # 記事の作者、編集者、管理者のみ承認可能
  def approve?
    article_owner? || editor_or_above?
  end

  # 報告（スパム報告など）
  # ログインユーザーのみ報告可能
  def report?
    logged_in?
  end

  # 許可される属性
  #
  # @return [Array<Symbol>]
  def permitted_attributes
    [:content]
  end

  # スコープ
  # 表示可能なコメントをフィルタリング
  class Scope < Scope
    def resolve
      if !admin? && scope.column_names.include?("approved")
        # 一般ユーザーは承認済みのコメントのみ表示
        scope.where(approved: true)
      else
        # 管理者、もしくはモデレーション機能がない場合はすべて表示
        scope.all
      end
    end

    # 特定の記事のコメントを返すスコープ
    def for_article(article)
      resolve.where(article: article)
    end

    # 報告されたコメントを返すスコープ（管理者用）
    def reported
      if admin? && scope.column_names.include?("reported")
        scope.where(reported: true)
      else
        scope.none
      end
    end
  end

  private

  # 記事の作者かどうかを確認
  def article_owner?
    logged_in? && record.article.user == user
  end
end
