class YandexAccount < ApplicationRecord
  belongs_to :user

  validates :login, presence: true
  validates :login, uniqueness: { case_sensitive: false }
  validates :user_id, uniqueness: true

  before_validation :normalize

  scope :verified, -> { where.not(verified_at: nil) }

  def self.for_login(login)
    return if login.blank?

    where('LOWER(login) = ?', login.to_s.strip.downcase).first
  end

  def verified?
    verified_at.present?
  end

  def name
    display_name.presence || login
  end

  private

  def normalize
    self.login = login.to_s.strip.presence
    self.guid = guid.to_s.strip.presence
  end
end
