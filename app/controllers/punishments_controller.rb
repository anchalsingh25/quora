class PunishmentsController < ApplicationController
  before_action :user_auth
  before_action :user_role_reviewer?

  def index
    punishments = Punishment.includes(:user).where(filter_params).order(created_at: :desc)
                            .paginate(page: params[:page], per_page: 20)

    render json: punishments, status: :ok
  end

  def create
    user = User.find_by(email_id: punishment_params[:email_id])
    return render json: { message: 'user not found' }, status: :not_found if user.nil?

    last_punishment = user.punishments.last

    if last_punishment&.restricted? || last_punishment&.permanent_ban?
      return render json: { message: 'User is already serving a restricted access period.' },
                    status: :unprocessable_entity
    end

    punishment = Punishment.new(user:, punishment_type: punishment_params[:punishment_type],
                                restriction_time: punishment_params[:restriction_time])

    return render json: { errors: report.errors.full_messages }, status: :unprocessable_entity unless punishment.save

    UserMailer.with(name: user.name, email: user.email_id).ban_email.deliver_later if punishment.permanent_ban?
    render json: { data: { message: 'user is punished' } }, status: :created
  end

  private

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
