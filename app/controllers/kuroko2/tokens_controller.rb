class Kuroko2::TokensController < Kuroko2::ApplicationController

  before_action :set_token, only: %i(update)
  before_action :set_engine, only: %i(update)

  def index
    @definition = JobDefinition.find(tokens_params[:job_definition_id])
    @instance   = JobInstance.find(tokens_params[:job_instance_id])
    @tokens     = @instance.tokens

    render layout: false
  end

  def update
    @instance = @token.job_instance

    case params[:invoke]
    when 'skip'
      @instance.logs.info("Skipped by #{current_user.name}.")

      @engine.skip(@token)
    when 'retry'
      @instance.logs.info("Retry by #{current_user.name}.")

      @engine.retry(@token)
    else
      raise HTTP::BadRequest
    end

    redirect_to job_definition_job_instance_path(job_definition_id: @token.job_definition_id, id: @token.job_instance.id)
  end

  private

  def set_engine
    @engine = Workflow::Engine.new
  end

  def set_token
    @token = Token.where(job_definition_id: params[:job_definition_id], job_instance_id: params[:job_instance_id]).find(params[:id])
  end

  def tokens_params
    params.permit(:job_definition_id, :job_instance_id)
  end

end
