class Kuroko2::Api::JobDefinitionsController < Kuroko2::Api::ApplicationController
  include Garage::RestfulActions

  private

  def require_resources
  end

  def create_resource
    definition = Kuroko2::JobDefinition.new(definition_params(params))
    user_ids = admin_id_params(params)
    definition.admins = Kuroko2::User.active.with(user_ids)

    if definition.save
      definition.admins.each do |user|
        user.stars.create(job_definition: definition) if user.google_account?
      end
      
      @resource = Kuroko2::Api::JobDefinitionResource.new(definition)
    else
      raise WeakParameters::ValidationError.new("#{definition.name}: #{definition.errors.full_messages.join()}")
    end
  end

  def require_resource
    definition = Kuroko2::JobDefinition.find(params[:id])
    @resource = Kuroko2::Api::JobDefinitionResource.new(definition)
  end
  
  def update_resource
    definition = Kuroko2::JobDefinition.find(params[:id])
    definition.update_attributes(definition_params(params))
    @resource = Kuroko2::Api::JobDefinitionResource.new(definition)
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

  def admin_id_params(params)
    params.permit(user_id: []).
      try!(:[], :user_id).
      try!(:reject, &:blank?).
      try!(:map, &:to_i) || []
  end
end
