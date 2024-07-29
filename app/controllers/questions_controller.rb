class QuestionsController < ApplicationController
  before_action :set_question, only: %i[update destroy]

  def create
    question = Question.new(question_param)
    return render json: { message: question.errors }, status: :unprocessable_entity unless question.save

    render json: question, status: :created
  end

  def index
    questions = Question.all
    render json: questions
  end

  def set_question
    @question = Question.find(params[:id])
    return render json: { message: 'Question not found' }, status: :not_found if @question.nil?
  end

  def update
    unless @question.update(question_param)
      return render json: { message: 'Question updation failed' },
                    status: :unprocessable_entity
    end

    render json: @question
  end

  def destroy
    @question.destroy
    render status: :no_content
  end

  private

  def question_param
    params.require(:question).permit(:title, :description)
  end
end
