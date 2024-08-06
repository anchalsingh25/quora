class UsersController < ApplicationController
  before_action :user_auth, only: %i[logout delete_current_user]

  def register
    user = User.new(user_params)
    return render json: { message: user.errors }, status: :unprocessable_entity unless user.save

    token = encode_token(user_id: user.id)
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

  private

  def user_params
    params.permit(:name, :email_id, :password)
  end
end
