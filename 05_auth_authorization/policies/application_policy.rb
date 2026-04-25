# frozen_string_literal: true

# ApplicationPolicy
# すべてのポリシークラスの基底クラスです
# デフォルトではすべてのアクションを拒否します

class ApplicationPolicy
  attr_reader :user, :record

  # ポリシーの初期化
  #
  # @param user [User] 現在のユーザー（nilの場合はゲスト）
  # @param record [ApplicationRecord] 対象のレコード
  def initialize(user, record)
    @user = user
    @record = record
  end

  # 一覧表示の権限
  def index?
    false
  end

  # 詳細表示の権限
  def show?
    false
  end

  # 作成の権限
  def create?
    false
  end

  # 新規作成フォームの表示権限（createと同じ）
  def new?
    create?
  end

  # 更新の権限
  def update?
    false
  end

  # 編集フォームの表示権限（updateと同じ）
  def edit?
    update?
  end

  # 削除の権限
  def destroy?
    false
  end

  # スコープクラス
  # 表示可能なレコードをフィルタリングします
  class Scope
    attr_reader :user, :scope

    # スコープの初期化
    #
    # @param user [User] 現在のユーザー
    # @param scope [ActiveRecord::Relation] 対象のスコープ
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    # 表示可能なレコードを返す
    # サブクラスでオーバーライドする必要があります
    #
    # @return [ActiveRecord::Relation]
    def resolve
      raise NotImplementedError, "You must define #resolve in #{self.class}"
    end

    private

    # 管理者かどうかを確認
    def admin?
      user&.admin?
    end

    # 編集者以上かどうかを確認
    def editor_or_above?
      user&.editor? || admin?
    end

    # ログイン済みかどうかを確認
    def logged_in?
      user.present?
    end
  end

  private

  # 管理者かどうかを確認
  def admin?
    user&.admin?
  end

  # 編集者以上かどうかを確認
  def editor_or_above?
    user&.editor? || admin?
  end

  # ログイン済みかどうかを確認
  def logged_in?
    user.present?
  end

  # レコードの所有者かどうかを確認
  def owner?
    logged_in? && record.respond_to?(:user) && record.user == user
  end
end
