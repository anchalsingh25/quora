class AnswersController < ApplicationController
  before_action :user_auth, except: %i[index]
  before_action :set_answer, only: %i[update destroy]
  before_action :validate_owner, only: %i[update destroy]
  before_action :check_restriction, only: %i[create]

  def index
    per_page = (params[:per_page] || 10).to_i
    per_page = 10 if per_page > 20
    page = (params[:page] || 1).to_i
    page = 1 if page < 1

    answer_per_page = Answer.includes(:user).paginate(page:, per_page:)

    answers = answer_per_page.map do |answer|
      {
        answer_id: answer.id,
        explanation: answer.explanation,
        user: answer.user.name
      }
    end

    meta = {
      total_number_of_pages: answer_per_page.total_pages,
      current_page: answer_per_page.current_page,
      number_of_record_in_current_page: answer_per_page.length,
      previous_page_exist: answer_per_page.previous_page.present?,
      next_page_exist: answer_per_page.next_page.present?
    }

    render json: { answer: answers, metadata: meta }, status: :ok
  end

  def create
    question = Question.find_by(id: answer_params[:question_id])
    return render json: { message: 'question not found' }, status: :not_found if question.nil?

    answer = Answer.new(answer_params.merge(user_id: @current_user.id))
    return render json:  { message: answer.errors }, status: :unprocessable_entity unless answer.save

    render json: answer, status: :created
  end

  def update
    unless @answer.update(explanation: answer_params[:explanation])
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

  def validate_owner
    message = case action_name
              when 'update'
                'Not authorized to update the answer'
              when 'destroy'
                'Not authorized to delete the answer'
              end
    return render json: { message: }, status: :unauthorized if @answer.user_id != @current_user.id
  end

  def set_answer
    @answer = Answer.find_by(id: params[:id])
    return render json: { message: 'Answer not found' }, status: :not_found if @answer.nil?
  end

  def answer_params
    params.require(:answer).permit(:explanation, :question_id)
  end
end
