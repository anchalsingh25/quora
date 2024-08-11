class ReassignAndDeleteUserJob
  include Sidekiq::Worker

  def perform
    users = User.where('deleted_at < ?', DateTime.now - User::RECOVERY_TIME)
  
    users.each do |user|
      user.reassign_data_to_dummy_user
      user.destroy
    end
  end
end
