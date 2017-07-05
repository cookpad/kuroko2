class Kuroko2::JobSuspendSchedulesController < Kuroko2::ApplicationController
  before_action :set_definition, only: %i(index create destroy)

  def index
    @suspend_schedules = @definition.job_suspend_schedules
    @suspend_schedule  = Kuroko2::JobSuspendSchedule.new
    render layout: false
  end

  def create
    suspend_schedule = @definition.job_suspend_schedules.create(job_suspend_schedule_params)

    if suspend_schedule.valid?
      render json: suspend_schedule, status: :created
    else
      render json: suspend_schedule.errors.full_messages, status: :bad_request
    end
  end

  def destroy
    suspend_schedule = Kuroko2::JobSuspendSchedule.find(params[:id])
    if suspend_schedule.destroy
      render json: suspend_schedule, status: :ok
    else
      render json: suspend_schedule, status: :bad_request
    end
  end

  private

  def job_suspend_schedule_params
    params.require(:job_suspend_schedule).permit(:cron)
  end

  def set_definition
    @definition = Kuroko2::JobDefinition.find(params[:job_definition_id])
  end
end
