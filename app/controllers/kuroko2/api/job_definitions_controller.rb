class Kuroko2::Api::JobDefinitionsController < Kuroko2::Api::ApplicationController
  include Garage::RestfulActions

  private

  def require_resources
    definitions = Kuroko2::JobDefinition.includes(:tags, :job_schedules)
    if params[:tags].present?
      definitions = definitions.tagged_by(params[:tags])
    end
    @resources = definitions.ordered.map { |definition| Kuroko2::Api::JobDefinitionResource.new(definition) }
  end

  def create_resource
    definition = Kuroko2::JobDefinition.new(definition_params(params))
    user_ids = admin_id_params(params)
    definition.admins = Kuroko2::User.active.with(user_ids)
    definition.tags = tags(params)

    if definition.save_and_record_revision
      definition.job_schedules = job_schedules(params, definition)
      definition.admins.each do |user|
        user.stars.create(job_definition: definition) if user.google_account?
      end

      @resource = Kuroko2::Api::JobDefinitionResource.new(definition)
    else
      raise Http::UnprocessableEntity.new("#{definition.name}: #{definition.errors.full_messages.join}")
    end
  end

  def require_resource
    definition = Kuroko2::JobDefinition.includes(:tags, :job_schedules, :admins).find(params[:id])
    @resource = Kuroko2::Api::JobDefinitionResource.new(definition)
  end

  def update_resource
    definition = Kuroko2::JobDefinition.find(params[:id])
    definition.tags = tags(params)
    definition.job_schedules = job_schedules(params, definition)

    if definition.update_and_record_revision(definition_params(params))
      @resource = Kuroko2::Api::JobDefinitionResource.new(definition)
    else
      raise Http::UnprocessableEntity.new("#{definition.name}: #{definition.errors.full_messages.join}")
    end
  end

  def destroy_resource
    @resource.destroy
  end

  def definition_params(params)
    params.permit(
      :name,
      :description,
      :script,
      :notify_cancellation,
      :hipchat_room,
      :hipchat_notify_finished,
      :suspended,
      :prevent_multi,
      :prevent_multi_on_failure,
      :hipchat_additional_text,
      :text_tags,
      :api_allowed,
      :slack_channel,
      :webhook_url)
  end

  def tags(params)
    tag_strings = params.permit(tags: []).fetch(:tags, [])
    tag_strings.map do |name|
      Kuroko2::Tag.find_or_create_by(name: name)
    end
  end

  def job_schedules(params, definition)
    cron_strings = params.permit(cron: []).fetch(:cron, [])
    cron_strings.map do |cron|
      schedule = definition.job_schedules.find_or_create_by(cron: cron)
      raise Http::UnprocessableEntity.new("#{cron}: #{schedule.errors.full_messages.join}") unless schedule.valid?
      schedule
    end
  end

  def admin_id_params(params)
    params.permit(user_id: []).
      try!(:[], :user_id).
      try!(:reject, &:blank?).
      try!(:map, &:to_i) || []
  end
end
