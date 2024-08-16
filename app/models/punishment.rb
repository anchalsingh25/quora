class Punishment < ApplicationRecord
  belongs_to :user
  enum punishment_type: [ :restricted_access, :permanent_ban]

  def restricted?
    restricted_access? && restriction_time > Time.current
  end
end
