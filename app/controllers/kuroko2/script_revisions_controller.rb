class Kuroko2::ScriptRevisionsController < Kuroko2::ApplicationController
  def index
    @definition = Kuroko2::JobDefinition.find(params[:job_definition_id])

    @revisions = @definition.revisions.includes(:user)
  end
end
