class QuestionsController < ApplicationController
  before_action :user_auth, except: %i[index show]
  before_action :set_question, only: %i[update destroy show]
  before_action :validate_owner, only: %i[update destroy]

  def create
    question = Question.new(question_param.merge(user_id: @current_user.id))
    return render json: { message: question.errors }, status: :unprocessable_entity unless question.save

    render json: question, status: :created
  end

  def index
    questions = Question.all
    render json: questions
  end

  def user_questions
    questions = @current_user.questions
    if questions.empty?
      render json: [], status: :ok
    else
      render json: questions, status: :ok
    end
  end

  def show
    answer = @question.answers
    answer_array = Array(answer)
    render json: { question: @question, answer: answer_array }, status: :ok
  end

  def update
    unless @question.update(question_param)
      return render json: { message: @question.errors.full_messages },
                    status: :unprocessable_entity
    end
    render json: @question
  end

  def destroy
    unless @question.destroy
      return render json: { message: @question.errors.full_messages },
                    status: :unprocessable_entity
    end

    render status: :no_content
  end

  private

  def validate_owner
    return unless @question.user_id != @current_user.id

    message = case action_name
              when 'update'
                'Not authorized to update the question'
              when 'destroy'
                'Not authorized to delete the question'
              end
    render json: { message: }, status: :unauthorized
  end

  def set_question
    @question = Question.find_by(id: params[:id])
    return unless @question.nil?

    render json: { message: 'Question not found' }, status: :not_found
  end

  def question_param
    params.require(:question).permit(:title, :description)
  end
end
