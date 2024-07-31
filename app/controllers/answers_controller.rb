class AnswersController < ApplicationController
  before_action :user_auth, only: %i[create update destroy]
  before_action :set_answer, only: %i[update destroy]
  before_action :set_message, only: %i[update destroy]
  before_action :check_question_presence, only: %i[create update destroy]

  def index
    render json: Answer.all, status: :ok
  end

  def create
    answer = Answer.new(answer_params)
    answer.user_id = @current_user.id
    answer.question_id = question.id
    return render json:  { message: answer.errors }, status: :unprocessable_entity unless answer.save

    render json: answer, status: :created
  end

  def update
    return render json: { message: @message }, status: :unauthorized if @message.present?

    @answer.update(answer_params)
    render json: @answer, status: :ok
  end

  def destroy
    return render json: { message: @message }, status: :unauthorized if @message.present?

    @answer.destroy
    render json: @answer, status: :no_content
  end

  private

  def check_question_presence
    question = Question.find_by(id: answer_params[:question_id])
    return render json: { message: 'question not found' }, status: :not_found if question.nil?
  end

  def set_message
    return unless @answer.user_id != @current_user.id

    @message = case action_name
               when 'update'
                 'Not authorized to update the answer'
               when 'destroy'
                 'Not authorized to delete the answer'
               end
  end

  def set_answer
    @answer = Answer.find(params[:id])
    return render json: { message: 'Answer not found' }, status: :not_found if @answer.nil?
  end

  def answer_params
    params.require(:answer).permit(:explanation, :question_id)
  end
end
