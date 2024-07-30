class User < ApplicationRecord
  has_secure_password
  validates :name, presence: true
  validates :email_id, presence: true, uniqueness: true
  validates :password, length: { minimum: 8 }
end
