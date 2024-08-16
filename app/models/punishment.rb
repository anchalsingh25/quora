class Punishment < ApplicationRecord
  belongs_to :user
  enum punishment_type: [ :restricted_access, :permanent_ban]
end
