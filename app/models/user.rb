class User < ApplicationRecord
  RECOVERY_TIME = 30.days

  has_many :questions
  has_many :answers
  has_many :comments
  has_many :likes
  has_many :received_reports, class_name: 'Report', foreign_key: 'reportee_id', dependent: :destroy
  has_many :reports, class_name: 'Report', foreign_key: 'reporter_id', dependent: :destroy
  has_many :punishments, dependent: :destroy

  has_secure_password
  validates :name, presence: true
  validates :email_id, presence: true, uniqueness: true
  validates :password, length: { minimum: 8 }

  enum role: %i[user admin reviewer], default: 0

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

  def reassign_data_to_dummy_user
    @dummy_user = User.find_by(email_id: 'dummy@example.com') if @dummy_user.nil?
    questions.update_all(user_id: @dummy_user.id)
    answers.update_all(user_id: @dummy_user.id)
    comments.update_all(user_id: @dummy_user.id)
    likes.update_all(user_id: @dummy_user.id)
  end
end
