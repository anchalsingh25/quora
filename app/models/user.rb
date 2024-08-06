class User < ApplicationRecord
  RECOVERY_TIME = 30.days

  has_many :questions
  has_many :answers
  has_many :comments
  has_many :likes
  has_secure_password
  validates :name, presence: true
  validates :email_id, presence: true, uniqueness: true
  validates :password, length: { minimum: 8 }

  def permanently_deleted?
    return false if deleted_at.nil?

    deleted_at + RECOVERY_TIME < DateTime.now
  end

  def display_name
    deleted_at.present? ? 'Deleted User' : name
  end

  def temporarily_deleted?
    return false if deleted_at.nil?

    deleted_at + RECOVERY_TIME >= DateTime.now
  end
end
