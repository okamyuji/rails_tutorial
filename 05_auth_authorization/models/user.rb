# frozen_string_literal: true

# Userモデル
# Deviseによる認証機能を実装します

class User < ApplicationRecord
  # Deviseモジュールの設定
  # 必要なモジュールのみを有効化します
  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :rememberable,
         :validatable,
         :confirmable,
         :trackable,
         :lockable,
         :timeoutable,
         :omniauthable,
         omniauth_providers: %i[google_oauth2 facebook github]

  # 関連付け
  has_many :articles, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :permissions, dependent: :destroy

  # ロール定義
  # member: 一般ユーザー
  # editor: 編集者（公開記事を編集可能）
  # admin: 管理者（すべての操作が可能）
  enum role: { member: 0, editor: 1, admin: 2 }

  # バリデーション
  validates :name, presence: true, length: { minimum: 2, maximum: 50 }
  validates :email, presence: true, uniqueness: { case_sensitive: false }

  # コールバック
  after_initialize :set_default_role, if: :new_record?
  before_save :downcase_email

  # スコープ
  scope :admins, -> { where(role: :admin) }
  scope :editors, -> { where(role: :editor) }
  scope :members, -> { where(role: :member) }
  scope :active, -> { where.not(confirmed_at: nil) }
  scope :locked, -> { where.not(locked_at: nil) }

  # OmniAuthからユーザーを作成または取得
  #
  # @param auth [OmniAuth::AuthHash] OmniAuthの認証情報
  # @return [User] ユーザーオブジェクト
  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.name = auth.info.name || auth.info.nickname
      user.avatar_url = auth.info.image

      # メール確認をスキップ（外部プロバイダで確認済みのため）
      user.skip_confirmation! if user.respond_to?(:skip_confirmation!)
    end
  end

  # 新しいOmniAuthセッションデータからユーザーを作成
  #
  # @param data [Hash] セッションに保存されたOAuthデータ
  # @return [User] ユーザーオブジェクト
  def self.new_with_session(params, session)
    super.tap do |user|
      if (data = session["devise.oauth_data"])
        user.email = data["info"]["email"] if user.email.blank?
        user.name = data["info"]["name"] if user.name.blank?
        user.provider = data["provider"]
        user.uid = data["uid"]
      end
    end
  end

  # 管理者かどうかを確認
  #
  # @return [Boolean]
  def admin?
    role == "admin"
  end

  # 編集者以上の権限があるかを確認
  #
  # @return [Boolean]
  def editor_or_above?
    editor? || admin?
  end

  # アカウントがアクティブかどうかを確認
  #
  # @return [Boolean]
  def active?
    confirmed_at.present? && locked_at.nil?
  end

  # フルネームを取得（存在しない場合はメールアドレスの一部を返す）
  #
  # @return [String]
  def display_name
    name.presence || email.split("@").first
  end

  # アバターURLを取得（存在しない場合はGravatarを返す）
  #
  # @param size [Integer] 画像サイズ
  # @return [String]
  def avatar_url_with_fallback(size: 80)
    avatar_url.presence || gravatar_url(size: size)
  end

  # 記事を公開する権限があるかを確認
  #
  # @param article [Article] 記事オブジェクト
  # @return [Boolean]
  def can_publish?(article)
    admin? || editor? || article.user == self
  end

  # 特定のリソースに対する権限を確認
  #
  # @param resource [ApplicationRecord] リソースオブジェクト
  # @param action [Symbol] アクション名
  # @return [Boolean]
  def has_permission?(resource, action)
    return true if admin?

    permissions.exists?(
      resource_type: resource.class.name,
      resource_id: resource.id,
      action: action
    )
  end

  private

  # デフォルトのロールを設定
  def set_default_role
    self.role ||= :member
  end

  # メールアドレスを小文字に変換
  def downcase_email
    self.email = email.downcase if email.present?
  end

  # GravatarのURLを生成
  #
  # @param size [Integer] 画像サイズ
  # @return [String]
  def gravatar_url(size: 80)
    hash = Digest::MD5.hexdigest(email.downcase)
    "https://www.gravatar.com/avatar/#{hash}?s=#{size}&d=identicon"
  end
end

# マイグレーション例:
#
# class DeviseCreateUsers < ActiveRecord::Migration[8.0]
#   def change
#     create_table :users do |t|
#       ## Database authenticatable
#       t.string :email,              null: false, default: ""
#       t.string :encrypted_password, null: false, default: ""
#
#       ## Recoverable
#       t.string   :reset_password_token
#       t.datetime :reset_password_sent_at
#
#       ## Rememberable
#       t.datetime :remember_created_at
#
#       ## Trackable
#       t.integer  :sign_in_count, default: 0, null: false
#       t.datetime :current_sign_in_at
#       t.datetime :last_sign_in_at
#       t.string   :current_sign_in_ip
#       t.string   :last_sign_in_ip
#
#       ## Confirmable
#       t.string   :confirmation_token
#       t.datetime :confirmed_at
#       t.datetime :confirmation_sent_at
#       t.string   :unconfirmed_email
#
#       ## Lockable
#       t.integer  :failed_attempts, default: 0, null: false
#       t.string   :unlock_token
#       t.datetime :locked_at
#
#       ## OmniAuth
#       t.string :provider
#       t.string :uid
#       t.string :avatar_url
#
#       ## カスタム属性
#       t.string :name
#       t.integer :role, default: 0
#
#       t.timestamps null: false
#     end
#
#     add_index :users, :email,                unique: true
#     add_index :users, :reset_password_token, unique: true
#     add_index :users, :confirmation_token,   unique: true
#     add_index :users, :unlock_token,         unique: true
#     add_index :users, [:provider, :uid],     unique: true
#   end
# end
