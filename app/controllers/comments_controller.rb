class CommentsController < ApplicationController
  before_action :user_auth

  def create
    comment = Comment.create(comment_params.merge(user_id: @current_user.id))
    return render json: { message: comment.errors.full_messages }, status: :unprocessable_entity unless comment.save

    render json: comment, status: :created
  end

  def index
    # TODO: send like count with each comment
    comments = Comment.where(answer_id: params[:answer_id]).includes(:user).map do |comment|
      {
        id: comment.id,
        comment: comment.content,
        user_name: comment.user.name
      }
    end
    render json: comments, status: :ok
  end

  def destroy
    comment = Comment.find_by(id: params[:id])
    return render json: { message: 'Comment Not found' }, status: :not_found if comment.nil?

    if comment.user_id != @current_user.id
      return render json: { message: 'you are not authorized to delete this comment' },
                    status: :unauthorized
    end

    unless comment.destroy
      return render json: { message: comment.errors.full_messages },
                    status: :unprocessable_entity
    end
    render json: { message: 'comment deleted succefully' }, status: :no_content
  end

  private

  def comment_params
    params.require(:comment).permit(:content, :answer_id)
  end
end
