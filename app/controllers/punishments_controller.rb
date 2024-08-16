class PunishmentsController < ApplicationController
  before_action :user_auth
  before_action :is_reviewer
  before_action :check_restriction, except: %i[index]

  def index
    punishments = Punishment.includes(:user).where(filter_params).order(created_at: :desc)
                            .paginate(page: params[:page], per_page: 20)

    render json: punishments, status: :ok
  end

  def create
    user = User.find_by(email_id: punishment_params[:email_id])
    return render json: { message: 'user not found' }, status: :not_found if user.nil?

    last_punishment = user.punishments.last

    if last_punishment&.restricted_access? && last_punishment.restriction_time > Time.current
      return render json: { message: 'User is already serving a restricted access period.' },
                    status: :unprocessable_entity
    end

    punishment = Punishment.new(user:, punishment_type: punishment_params[:punishment_type],
                                restriction_time: punishment_params[:restriction_time])

    return render json: { errors: report.errors.full_messages }, status: :unprocessable_entity unless punishment.save

    render json: { data: { message: 'user is punished' } }, status: :created
  end

  private

  def is_reviewer
    return render json: { message: 'You are not reviewer' } if @current_user.role != 'reviewer'
  end

  def filter_params
    filter = {}
    filter['users.email_id'] = params[:email_id] if params[:email_id].present?
    filter['punishments.punishment_type'] = params[:punishment_type] if params[:punishment_type].present?
    filter
  end

  def punishment_params
    params.permit(:email_id, :restriction_time, :punishment_type)
  end
end
