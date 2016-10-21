class Kuroko2::JobInstancesController < Kuroko2::ApplicationController
  before_action :set_definition, only: %i(index create show destroy force_destroy)
  before_action :set_instance, only: %i(show destroy force_destroy)

  def index
    @instances = @definition.job_instances.page(page_params[:page])

    render layout: false
  end

  def create
    if params[:job_definition].present?
      @instance = @definition.job_instances.create(params.require(:job_definition).permit(:script))
    else
      @instance = @definition.job_instances.create
    end

    if @instance
      @instance.logs.info("Launched by #{current_user.name}.")

      redirect_to job_definition_job_instance_path(@definition, @instance)
    else
      raise HTTP::BadRequest
    end
  end

  def show
    @logs   = @instance.logs
    @tokens = @instance.tokens

    if params[:mode] == :naked
      render partial: 'instance', layout: false
    else
      # render
    end
  end

  def destroy
    if @instance.cancelable?
      ActiveRecord::Base.transaction { @instance.cancel(by: current_user.name) }
    end

    redirect_to job_definition_job_instance_path(@definition, @instance)
  end

  def force_destroy
    ActiveRecord::Base.transaction do
      @instance.executions.each do |execution|
        execution = Kuroko2::Worker.executing(execution.id)
        execution.update_column(:execution_id, nil) if execution
      end

      @instance.cancel(by: current_user.name)
    end

    message = "Force canceled by #{current_user.name}."
    @instance.logs.warn(message)
    Kuroko2.logger.warn(message)

    redirect_to job_definition_job_instance_path(@definition, @instance)
  end

  def working
    @instances = Kuroko2::JobInstance.working.order(id: :desc).joins(job_definition: :admins).includes(job_definition: :admins)
  end

  private
  def job_instance_params
    params.permit(:job_definition_id, :id)
  end

  def page_params
    params.permit(:page)
  end

  def set_definition
    @definition = Kuroko2::JobDefinition.find(job_instance_params[:job_definition_id])
  end

  def set_instance
    @instance = @definition.job_instances.find(job_instance_params[:id])
  end
end
