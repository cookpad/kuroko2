class Kuroko2::JobSchedulesController < Kuroko2::ApplicationController
  before_action :set_definition, only: %i(index create destroy)

  def index
    @schedules = @definition.job_schedules
    @schedule  = JobSchedule.new

    render layout: false
  end

  def create
    schedule = @definition.job_schedules.create(job_schedule_params)

    if schedule.valid?
      render json: schedule, status: :created
    else
      render json: schedule, status: :bad_request
    end
  end

  def destroy
    schedule = JobSchedule.find(params[:id])
    if schedule.destroy
      render json: schedule, status: :ok
    else
      render json: schedule, status: :bad_request
    end
  end

  private

  def job_schedule_params
    params.require(:job_schedule).permit(:cron)
  end

  def set_definition
    @definition = JobDefinition.find(params[:job_definition_id])
  end
end
