class LikesController < ApplicationController
  before_action :user_auth

  def create
    like = Like.create(like_params.merge(user_id: @current_user.id))
    return render json: { message: like.errors.full_messages }, status: :unprocessable_entity if !like.save

    render json: { data: like }, status: :created
  end

  def unlike
    like = Like.find_by(like_params.merge(user_id: @current_user.id))
    return render json: {message: "Like not found"}, status: :not_found if like.nil?
    return render json: { message: like.errors.full_messages }, status: :unprocessable_entity unless like.destroy

    render status: :no_content
  end

  def like_params
    params.require(:like).permit(:likable_id, :likable_type)
  end
end
