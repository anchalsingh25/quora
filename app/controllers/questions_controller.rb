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
    render json: @current_user.questions, status: :ok
  end

  def show
    answers = @question.answers.includes(:user).map do |answer|
      {
        description: answer.explanation,
        written_by: answer.user.name,
        created_at: answer.created_at
      }
    end
    render json: { question: @question.title, answers: }, status: :ok
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
    message = case action_name
              when 'update'
                'Not authorized to update the question'
              when 'destroy'
                'Not authorized to delete the question'
              end
    return render json: { message: }, status: :unauthorized if @answer.user_id != @current_user.id
  end

  def set_question
    @question = Question.find_by(id: params[:id])
    render json: { message: 'Question not found' }, status: :not_found if @question.nil?
  end

  def question_param
    params.require(:question).permit(:title, :description)
  end
end
