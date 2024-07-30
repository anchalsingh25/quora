class AnswersController < ApplicationController
  before_action :user_auth, only: %i[create update destroy]
  before_action :set_answer, only: %i[update destroy]

  def index
    render json: Answer.all, state: :ok
  end

  def create
    question = Question.find_by(id: answer_params[:question_id])
    return render json: { message: 'question not found' }, status: :not_found if question.nil?

    answer = Answer.new(answer_params)
    answer.user_id = @current_user.id
    answer.question_id = question.id
    return render json:  { message: answer.errors }, status: :unprocessable_entity unless answer.save

    render json: answer, status: :created
  end

  def update
    if @answer.user_id != @current_user.id
      return render json: { message: 'not authorized to update the answer' },
                    status: :unauthorized
    end

    answer = Answer.find_by(question_id: answer_params[:question_id])
    return render json: { message: 'Your answer not found' }, status: :not_found if answer.nil?

    @answer.update(answer_params)
    render json: @answer, status: :ok
  end

  def destroy
    if @answer.user_id != @current_user.id
      return render json: { message: 'not authorized to delete the answer' },
                    status: :unauthorized
    end

    answer = Answer.find_by(question_id: answer_params[:question_id])
    return render json: { message: 'Your answer not found' }, status: :not_found if answer.nil?

    @answer.destroy
    render json: @answer, status: :no_content
  end

  private

  def set_answer
    @answer = Answer.find(params[:id])
    return render json: { message: 'Answer not found' }, status: :not_found if @answer.nil?
  end

  def answer_params
    params.require(:answer).permit(:explanation, :question_id)
  end
end
