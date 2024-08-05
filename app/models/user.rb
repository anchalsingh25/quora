class User < ApplicationRecord
  has_many :questions
  has_many :answers
  has_many :comments
  has_many :likes
  has_secure_password
  validates :name, presence: true
  validates :email_id, presence: true, uniqueness: true
  validates :password, length: { minimum: 8 }

  def deleted?
    deleted_at.present?
  end

  def display_name
    deleted? ? 'deleted_user' : name
  end

  def can_be_restored?
    deleted? && deleted_at >= 30.days.ago
  end

  def restore
    can_be_restored? && update_column(:deleted_at, nil)
  end
end
