class Kuroko2::ExecutionsController < Kuroko2::ApplicationController

  before_action :set_execution, only: %i(destroy)

  def working
    @executions = Kuroko2::Execution.where(finished_at: nil).order(created_at: :desc).includes(job_instance: :job_definition)
  end

  def destroy
    if @execution.try(:pid)
      hostname = Kuroko2::Worker.executing(@execution.id).try(:hostname)
      Kuroko2::ProcessSignal.create!(pid: @execution.pid, hostname: hostname) if hostname
    end

    redirect_to job_definition_job_instance_path(job_definition_id: execution_params[:job_definition_id], id: execution_params[:job_instance_id])
  end

  private

  def set_execution
    @execution = Kuroko2::Execution.where(job_definition_id: execution_params[:job_definition_id], job_instance_id: execution_params[:job_instance_id], id: execution_params[:id]).take
  end

  def execution_params
    params.permit(:id, :job_definition_id, :job_instance_id)
  end

end
