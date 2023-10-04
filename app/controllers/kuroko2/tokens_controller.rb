class Kuroko2::TokensController < Kuroko2::ApplicationController

  before_action :set_token, only: %i(update)
  before_action :set_engine, only: %i(update)

  def index
    @definition = Kuroko2::JobDefinition.find(tokens_params[:job_definition_id])
    @instance   = Kuroko2::JobInstance.find(tokens_params[:job_instance_id])
    @tokens     = @instance.tokens

    render layout: false
  end

  def update
    @instance = @token.job_instance

    case
    when params[:invoke] == 'skip' && @token.skippable?
      @instance.logs.info("Skipped by #{current_user.name}.")

      @engine.skip(@token)
    when params[:invoke] == 'retry' && @token.retryable?
      @instance.logs.info("Retry by #{current_user.name}.")

      @engine.retry(@token)
    else
      raise Http::BadRequest
    end

    redirect_to job_definition_job_instance_path(job_definition_id: @token.job_definition_id, id: @token.job_instance.id)
  end

  private

  def set_engine
    @engine = Kuroko2::Workflow::Engine.new
  end

  def set_token
    @token = Kuroko2::Token.where(job_definition_id: params[:job_definition_id], job_instance_id: params[:job_instance_id]).find(params[:id])
  end

  def tokens_params
    params.permit(:job_definition_id, :job_instance_id)
  end

end
