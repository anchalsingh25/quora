class UsersController < ApplicationController
  before_action :user_auth, only: [:logout]

  def register
    user = User.new(user_params)
    return render json: { message: user.errors }, status: :unprocessable_entity unless user.save

    token = encode_token(user_id: user.id)
    render json: { name: user.name, email_id: user.email_id, token: }, status: :created
  end

  def login
    user = User.find_by(email_id: user_params[:email_id])
    if user.nil? || !user.authenticate(user_params[:password])
      return render json: { message: 'unauthorized access' },
                    status: :unauthorized
    end

    token = encode_token(user_id: user.id)
    render json: { message: 'user logged in', token: }, status: :ok
  end

  def logout
    token = request.headers['Authorization'].split(' ')[1]
    BlacklistToken.create(token: token)
    render json: { message: 'successfully logged out' }, status: :ok
  end

  private

  def user_params
    params.permit(:name, :email_id, :password)
  end
end
