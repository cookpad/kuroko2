class ExecutionLogsController < ApplicationController
  def index
    @definition = JobDefinition.find(logs_params[:job_definition_id])
    @instance   = JobInstance.find(logs_params[:job_instance_id])

    execution_logger = ExecutionLogger.
      get_logger(stream_name: "JOB#{sprintf("%010d", @definition.id)}/#{@instance.id}")

    @response = execution_logger.get_logs(logs_params[:token])
  rescue ExecutionLogger::NotFound
    head 404
  end

  private

  def logs_params
    params.permit(:job_definition_id, :job_instance_id, :token)
  end
end
