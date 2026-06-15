class User < ApplicationRecord
  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :rememberable,
         :validatable

  has_many :articles, dependent: :destroy
  has_many :comments, dependent: :nullify
  has_many :memberships, dependent: :destroy
  has_many :groups, through: :memberships

  enum :role, { member: 0, editor: 1, admin: 2 }

  validates :name, presence: true

  after_initialize :set_default_role, if: :new_record?

  scope :admins, -> { where(role: :admin) }
  scope :editors, -> { where(role: :editor) }
  scope :members, -> { where(role: :member) }

  def admin?
    role == "admin"
  end

  def editor_or_above?
    editor? || admin?
  end

  def display_name
    name.presence || email.split("@").first
  end

  private

  def set_default_role
    self.role ||= :member
  end
end
