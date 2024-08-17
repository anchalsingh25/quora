class UsersController < ApplicationController
  before_action :user_auth, only: %i[logout delete_current_user]

  def register
    user = User.find_by(email_id: user_params[:email_id])

    if user.present?
      if user.temporarily_deleted? || user.deleted_at.nil?
        return render json: { message: 'user already exist' },
                      status: :unprocessable_entity
      end

      user.reassign_data_to_dummy_user
      user.update(user_params.merge(deleted_at: nil))
    end

    if user.nil?
      user = User.new(user_params)
      return render json: { message: user.errors }, status: :unprocessable_entity unless user.save
    end

    token = encode_token(user_id: user.id)
    UserMailer.with(name: user.name, email: user.email_id, user_id: user.id).welcome_email.deliver_later
    render json: { name: user.name, email_id: user.email_id, token: }, status: :created
  end

  def login
    user = User.find_by(email_id: user_params[:email_id])

    if user.nil? || user.permanently_deleted? || !user.authenticate(user_params[:password])
      return render json: { message: 'unauthorized access' },
                    status: :unauthorized
    end

    user.update_column(:deleted_at, nil) if user.temporarily_deleted?

    token = encode_token(user_id: user.id)
    render json: { message: 'user logged in', token: }, status: :ok
  end

  def logout
    token = request.headers['Authorization'].split(' ')[1]
    BlacklistToken.create(token:)
    render json: { message: 'successfully logged out' }, status: :ok
  end

  def delete_current_user
    unless @current_user.update_column(:deleted_at, Time.now)
      return render json: { message: @current_user.errors.full_messages },
                    status: :unprocessable_entity
    end
    token = request.headers['Authorization'].split(' ')[1]
    BlacklistToken.create(token:)
    render json: { message: 'Your account deleted successfully' }, status: :ok
  end

  def confirm_email
    decoded_token = JWT.decode(params[:token], ENV['AUTH_SECRET_KEY'])
    user_id = decoded_token[0]['user_id']
    user = User.find_by(id: user_id)
    return render json: { message: 'user not found' }, status: :not_found if user.nil?
    return render json: { message: 'You are already verified' }, status: :bad_request if user.email_verified?

    user.update_column(:email_verified, true)
    render json: { message: 'Email verification successful' }, status: :ok
  rescue JWT::DecodeError
    render json: { message: 'Invalid token' }, status: :bad_request
  end

  private

  def user_params
    params.permit(:name, :email_id, :password)
  end
end
