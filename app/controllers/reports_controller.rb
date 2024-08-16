class ReportsController < ApplicationController
  before_action :user_auth
  before_action :user_role_reviewer?, only: %i[index]

  def index
    reports = Report.includes(:reporter, :reportee)
    reports_per_page = reports.paginate(page: params[:page], per_page: 20)

    render json: {
      data: reports_per_page.map do |report|
        {
          category: report.category,
          reason: report.reason,
          status: report.status,
          reporter_email: report.reporter.email_id,
          reportee_email: report.reportee.email_id,
          resource: report.reportable
        }
      end
    }
  end

  def create
    if report_params[:category] == 'other' && report_params[:reason].nil?
      return render json: { error: 'Reason must be provided when category is other' }, status: :unprocessable_entity
    end

    if Report.categories.keys.exclude?(report_params[:category])
      return render json: { message: 'Not a valid Category type' },
                    status: :unprocessable_entity
    end

    if Report::VALID_REPORTABLE.exclude?(report_params[:reportable_type])
      return render json: { message: 'Not a valid Reportable type' },
                    status: :unprocessable_entity
    end

    resource = report_params[:reportable_type].constantize.find_by(id: report_params[:reportable_id])
    reportee = resource&.user
    return render json: { message: "You can't report yourself" }, status: :unauthorized if reportee == @current_user

    report = Report.new(report_params.merge(reporter_id: @current_user.id, reportee:))
    return render json: { errors: report.errors.full_messages }, status: :unprocessable_entity unless report.save

    render json: { data: { message: 'Report created' } }, status: :created
  end

  def update
    report = Report.find_by(id: params[:id])
    return render json: { error: 'Report not found' }, status: :not_found if report.nil?

    unless report.update(status: report_params[:status])
      return render json: { errors: report.errors.full_messages },
                    status: :unprocessable_entity
    end

    render json: { data: { message: 'Report status updated' } }, status: :ok
  end

  private

  def report_params
    params.require(:report).permit(:reportable_id, :reportable_type, :category, :reason, :status)
  end
end
