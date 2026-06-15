class User < ApplicationRecord
  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :rememberable,
         :validatable,
         :omniauthable,
         omniauth_providers: [:google_oauth2]

  has_many :articles, dependent: :destroy
  has_many :comments, dependent: :nullify
  has_many :memberships, dependent: :destroy
  has_many :groups, through: :memberships

  enum :role, { member: 0, editor: 1, admin: 2 }

  validates :name, presence: true

  def self.from_omniauth(auth)
    find_or_create_by(provider: auth.provider, uid: auth.uid) do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.name = auth.info.name
      user.skip_confirmation! if user.respond_to?(:skip_confirmation!)
    end
  end
end
