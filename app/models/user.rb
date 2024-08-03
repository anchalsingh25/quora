class User < ApplicationRecord
  has_many :questions, dependent: :destroy
  has_many :answers, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_secure_password
  validates :name, presence: true
  validates :email_id, presence: true, uniqueness: true
  validates :password, length: { minimum: 8 }
end
