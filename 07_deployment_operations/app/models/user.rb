class User < ApplicationRecord
  has_many :articles, dependent: :destroy
  has_many :comments, dependent: :nullify
  has_many :memberships, dependent: :destroy
  has_many :groups, through: :memberships

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
end
