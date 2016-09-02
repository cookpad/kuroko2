class Kuroko2::ExecutionLogsController < Kuroko2::ApplicationController
  def index
    @definition = Kuroko2::JobDefinition.find(logs_params[:job_definition_id])
    @instance   = Kuroko2::JobInstance.find(logs_params[:job_instance_id])

    execution_logger = Kuroko2::ExecutionLogger.
      get_logger(stream_name: "JOB#{sprintf("%010d", @definition.id)}/#{@instance.id}")

    @response = execution_logger.get_logs(logs_params[:token])
  rescue Kuroko2::ExecutionLogger::NotFound
    head 404
  end

  private

  def logs_params
    params.permit(:job_definition_id, :job_instance_id, :token)
  end
end
