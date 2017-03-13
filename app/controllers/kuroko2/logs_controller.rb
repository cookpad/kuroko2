class Kuroko2::LogsController < Kuroko2::ApplicationController
  def index
    @definition = Kuroko2::JobDefinition.find(logs_params[:job_definition_id])
    @instance   = Kuroko2::JobInstance.find(logs_params[:job_instance_id])
    @logs       = @instance.logs.order(:id)

    render layout: false
  end

  private

  def logs_params
    params.permit(:job_definition_id, :job_instance_id)
  end
end
