class Kuroko2::Api::JobInstancesController < Kuroko2::Api::ApplicationController
  include Garage::RestfulActions

  validates :create do
    hash :env, description: 'Env variables to launch an instance' do |env|
      env.to_h.all? { |_, v| v.is_a?(String) }
    end
  end

  private

  def require_resources
    protect_resource_as Kuroko2::Api::JobInstanceResource
  end

  def create_resource
    definition = Kuroko2::JobDefinition.find(params[:job_definition_id])
    unless definition.api_allowed?
      raise HTTP::Forbidden.new("#{definition.name} is not allowed to be executed via API")
    end

    instance = definition.job_instances.create(
      script: definition.script.prepend(env_script),
    )
    instance.logs.info("Launched by instances API (#{basic_user_name})")
    Kuroko2::Api::JobInstanceResource.new(instance)
  end

  def require_resource
    instance = Kuroko2::JobInstance.find(params[:id])
    @resource = Kuroko2::Api::JobInstanceResource.new(instance)
  end

  def env_script
    return '' unless params[:env]

    params[:env].permit!.to_h.map { |key, value|
      "env: #{key}='#{value.gsub("'", "\\\\'")}'"
    }.join("\n").concat("\n")
  end

  # Don't set location header
  def location
    nil
  end
end
