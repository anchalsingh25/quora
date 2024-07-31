class AnswersController < ApplicationController
  before_action :user_auth, except: %i[index]
  before_action :set_answer, only: %i[update destroy]
  before_action :validate_owner, only: %i[update destroy]
  before_action :check_question_presence, only: %i[create update]

  def index
    render json: Answer.all, status: :ok
  end

  def create
    answer = Answer.new(answer_params.merge(user_id: @current_user.id, question_id: answer_params[:question_id]))
    return render json:  { message: answer.errors }, status: :unprocessable_entity unless answer.save

    render json: answer, status: :created
  end

  def update
    unless @answer.update(answer_params)
      return render json: { message: @answer.errors.full_messages },
                    status: :unprocessable_entity
    end

    render json: @answer, status: :ok
  end

  def destroy
    unless @answer.destroy
      return render json: { message: @answer.errors.full_messages },
                    status: :unprocessable_entity
    end

    render json: @answer, status: :no_content
  end

  private

  def check_question_presence
    question = Question.find_by(id: answer_params[:question_id])
    return render json: { message: 'question not found' }, status: :not_found if question.nil?
  end

  def validate_owner
    return unless @answer.user_id != @current_user.id

    message = case action_name
              when 'update'
                'Not authorized to update the answer'
              when 'destroy'
                'Not authorized to delete the answer'
              end
    render json: { message: }, status: :unauthorized
  end

  def set_answer
    @answer = Answer.find_by(id: params[:id])
    return render json: { message: 'Answer not found' }, status: :not_found if @answer.nil?
  end

  def answer_params
    params.require(:answer).permit(:explanation, :question_id)
  end
end
