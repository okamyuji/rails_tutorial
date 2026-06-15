class Article < ApplicationRecord
  belongs_to :user, counter_cache: true
  has_many :comments, dependent: :destroy

  validates :title, presence: true, length: { minimum: 5, maximum: 200 }
  validates :content, presence: true, length: { minimum: 10 }
  validates :published_at, presence: true, if: :published?

  scope :published, -> { where(published: true) }
  scope :draft, -> { where(published: false) }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_user, ->(user_id) { where(user_id: user_id) }

  def publish!
    update!(published: true, published_at: Time.current)
  end

  def self.search(query)
    return all if query.blank?

    sanitized = sanitize_sql_like(query)
    where("title LIKE ? OR content LIKE ?", "%#{sanitized}%", "%#{sanitized}%")
  end
end
