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
    per_page = params[:per_page].to_i || 10
    per_page = 10 if per_page > 20
    page = (params[:page] || 1).to_i

    questions = Question.includes(answers: %i[user likes]).paginate(page:, per_page:)

    questions_and_answers = questions.map do |question|
      most_liked_answer = question.answers.max_by { |answer| answer.likes.size }
      {
        question_id: question.id,
        question_title: question.title,
        most_liked_answer: if most_liked_answer.present?
                             {
                               answer_id: most_liked_answer.id,
                               description: most_liked_answer.explanation,
                               written_by: most_liked_answer.user.name,
                               liked_count: most_liked_answer.likes.size,
                               created_at: most_liked_answer.created_at
                             }
                           end
      }
    end

    render json: {
      questions: questions_and_answers,
      total_number_of_pages: questions.total_pages,
      current_page: questions.current_page,
      number_of_record_in_current_page: questions.length,
      next_page_exist: questions.next_page.present?,
      previous_page_exist: questions.previous_page.present?
    }
  end

  def user_questions
    render json: @current_user.questions, status: :ok
  end

  def show
    render json: @question, status: :ok
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
