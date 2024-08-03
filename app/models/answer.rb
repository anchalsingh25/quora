class Answer < ApplicationRecord
  belongs_to :user
  belongs_to :question
  has_many :comments, dependent: :destroy
  has_many :likes, as: :likable, dependent: :destroy
end
