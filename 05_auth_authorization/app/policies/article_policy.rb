# frozen_string_literal: true

class ArticlePolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    true
  end

  def create?
    user.present?
  end

  def update?
    user.present? && (record.user == user || user.admin?)
  end

  def destroy?
    user.present? && (record.user == user || user.admin?)
  end

  class Scope < Scope
    def resolve
      user&.admin? ? scope.all : scope.where(published: true)
    end
  end
end
