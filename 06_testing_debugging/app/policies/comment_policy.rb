class CommentPolicy < ApplicationPolicy
  def create?
    logged_in?
  end

  def destroy?
    owner? || admin?
  end
end
