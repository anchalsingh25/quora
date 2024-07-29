class UsersController < ApplicationController
  def register
    @user = User.new(user_params)
    if @user.save
      render json: { name: @user.name, email_id: @user.email_id }, status: :created
    else
      render json: { message: @user.errors }, status: :unprocessable_entity
    end
  end

  def login
    user = User.find_by(email_id: user_params[:email_id])
    if user && user.authenticate(user_params[:password])
      render json: { message: 'user logged in' }, status: :ok
    else
      render json: { message: 'unauthorized access' }, status: :unauthorized
    end
  end

  def logout; end

  def user_params
    params.permit(:name, :email_id, :password)
  end
end
