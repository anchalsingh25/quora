class Report < ApplicationRecord
  VALID_REPORTABLE = %w[Comment Answer Question].freeze

  belongs_to :reportable, polymorphic: true
  belongs_to :reportee, class_name: 'User', foreign_key: 'reportee_id'
  belongs_to :reporter, class_name: 'User', foreign_key: 'reporter_id'

  enum :category, %i[spam harassment inappropriate_content other], default: :spam, validate: true

  enum :status, %i[pending resolved]

  validates :reporter_id,
            uniqueness: { scope: %i[reportable_id reportable_type], message: "You've already reported this item" }
  validates :reportable_type, inclusion: { in: VALID_REPORTABLE, message: '%<value>s is not a valid reportable type' }
  validates :category, inclusion: { in: categories.keys, message: '%<value>s is not a valid category' }
end
