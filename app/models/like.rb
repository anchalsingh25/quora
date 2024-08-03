class Like < ApplicationRecord
  VALID_LIKABLES = %w[Comment Answer].freeze
  belongs_to :likable, polymorphic: true
  belongs_to :user
  validates :user_id, uniqueness: { scope: %i[likable_id likable_type] }
  validates :likable_type, inclusion: { in: VALID_LIKABLES, message: '%<value>s is not a valid likable type' }
end
