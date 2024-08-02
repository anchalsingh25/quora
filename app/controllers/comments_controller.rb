class CommentsController < ApplicationController
  before_action :user_auth

  def create
    answer = Answer.find_by(id: comment_params[:answer_id])
    return render json: { message: 'Answer not found' }, status: :unprocessable_entity if answer.nil?

    comment = Comment.new(comment_params.merge(user_id: @current_user.id))
    return render json: { message: comment.errors.full_messages }, status: :unprocessable_entity unless comment.save

    render json: comment, status: :created
  end

  def destroy
    @comment = Comment.find_by(id: params[:id])
    return render json: { message: 'Comment Not found' }, status: :not_found if @comment.nil?

    unless @comment.destroy
      return render json: { message: @comment.errors.full_messages },
                    status: :unprocessable_entity
    end
    render json: { merge: 'comment deleted succefully' }, status: :no_content
  end

  private

  def comment_params
    params.require(:comment).permit(:content, :answer_id)
  end
end
