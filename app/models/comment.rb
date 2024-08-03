class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :answer
  has_many :likes, as: :likable, dependent: :destroy
end
