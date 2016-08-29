class LogsController < ApplicationController
  def index
    @definition = JobDefinition.find(logs_params[:job_definition_id])
    @instance   = JobInstance.find(logs_params[:job_instance_id])
    @logs       = @instance.logs

    render layout: false
  end

  private

  def logs_params
    params.permit(:job_definition_id, :job_instance_id)
  end
end
