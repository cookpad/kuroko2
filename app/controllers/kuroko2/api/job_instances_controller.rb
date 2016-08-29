class Kuroko2::Api::JobInstancesController < Kuroko2::Api::ApplicationController
  include Garage::RestfulActions

  validates :create do
    hash :env, description: 'Env variables to launch an instance' do |env|
      env.all? { |_, v| v.is_a?(String) }
    end
  end

  private

  def require_resources
    protect_resource_as Api::JobInstanceResource
  end

  def create_resource
    definition = JobDefinition.find(params[:job_definition_id])
    unless definition.api_allowed?
      raise HTTP::Forbidden.new("#{definition.name} is not allowed to be executed via API")
    end

    instance = definition.job_instances.create(
      script: definition.script.prepend(env_script),
    )
    instance.logs.info("Launched by instances API (#{basic_user_name})")
    Api::JobInstanceResource.new(instance)
  end

  def require_resource
    instance = JobInstance.find(params[:id])
    @resource = Api::JobInstanceResource.new(instance)
  end

  def env_script
    return '' unless params[:env]

    params[:env].map { |key, value|
      "env: #{key}='#{value.gsub("'", "\\\\'")}'"
    }.join("\n").concat("\n")
  end

  # Don't set location header
  def location
    nil
  end
end
