class QuestionsController < ApplicationController
  before_action :set_question, only: %i[update destroy]
  before_action :user_auth, only: %i[create update destroy user_questions]
  before_action :set_message, only: %i[update destroy]

  def create
    question = Question.new(question_param)
    question.user_id = @current_user.id
    return render json: { message: question.errors }, status: :unprocessable_entity unless question.save

    render json: question, status: :created
  end

  def index
    questions = Question.all
    render json: questions
  end

  def user_questions
    questions = @current_user.questions
    return render json: { message: 'no question created' }, status: :ok if questions.size.zero?

    render json: questions, status: :ok
  end

  def show
    question = Question.find(params[:id])
    render json: question
  end

  def update
    return render json: { message: @message }, status: :unauthorized if @message.present?

    unless @question.update(question_param)
      return render json: { message: 'Question updation failed' },
                    status: :unprocessable_entity
    end

    render json: @question
  end

  def destroy
    return render json: { message: @message }, status: :unauthorized if @message.present?

    @question.destroy
    render status: :no_content
  end

  private

  def set_message
    return unless @question.user_id != @current_user.id

    @message = case action_name
               when 'update'
                 'Not authorized to update the question'
               when 'destroy'
                 'Not authorized to delete the question'
               end
  end

  def set_question
    @question = Question.find(params[:id])
    return render json: { message: 'Question not found' }, status: :not_found if @question.nil?
  end

  def question_param
    params.require(:question).permit(:title, :description)
  end
end
