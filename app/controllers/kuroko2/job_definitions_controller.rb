class Kuroko2::JobDefinitionsController < Kuroko2::ApplicationController
  before_action :set_definition, only: [:show, :edit, :update, :destroy]

  def index
    rel = Kuroko2::JobDefinition.joins(:admins).includes(:tags, :job_schedules, :admins)
    query = query_params[:q]

    if query.present?
      rel = rel.search_by(query)
    end

    @input_tags = query_params[:tag] || []
    if @input_tags.present?
      rel = rel.tagged_by(@input_tags)
    end

    if query.present? || @input_tags.present?
      @related_tags = rel.includes(:tags).map(&:tags).flatten.uniq
    else
      @related_tags = Kuroko2::Tag.all
    end

    @definitions = rel.ordered.page(page_params[:page])
  end

  def show
    @instances = @definition.job_instances.page(0)
    @schedules = @definition.job_schedules
    @suspend_schedules = @definition.job_suspend_schedules

    @schedule  = Kuroko2::JobSchedule.new(job_definition: @definitions)
    @suspend_schedule = Kuroko2::JobSuspendSchedule.new(job_definition: @definitions)
  end

  def new
    @definition = Kuroko2::JobDefinition.new
    @definition.admins << current_user
  end

  def create
    @definition = Kuroko2::JobDefinition.new(definition_params)
    @definition.admins = Kuroko2::User.active.with(admin_id_params)

    if @definition.save
      current_user.stars.create(job_definition: @definition)

      redirect_to @definition, notice: 'Job Definition was successfully created.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    success = ActiveRecord::Base.transaction do
      @definition.attributes = definition_params
      @definition.admins     = Kuroko2::User.active.with(admin_id_params)

      @definition.save
    end

    if success
      redirect_to @definition, notice: 'Job Definition was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @definition.destroy

    redirect_to job_definitions_path, notice: 'Job Definition was successfully destroyed.'
  end

  private

  def admin_id_params
    params.require(:admin_assignments).permit(user_id: []).
      try!(:[], :user_id).
      try!(:reject, &:blank?).
      try!(:map, &:to_i) || []
  end

  def definition_params
    params.require(:job_definition).permit(:name, :description, :script, :notify_cancellation, :hipchat_room, :hipchat_notify_finished, :suspended, :prevent_multi, :prevent_multi_on_failure, :hipchat_additional_text, :text_tags, :api_allowed, :slack_channel, :webhook_url)
  end

  def query_params
    params.permit(:q, tag: [])
  end

  def page_params
    params.permit(:page)
  end

  def set_definition
    @definition = Kuroko2::JobDefinition.find(params[:id])
  end
end
