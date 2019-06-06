class Kuroko2::Api::JobDefinitionResource < Kuroko2::Api::ApplicationResource
  property :id

  property :name

  property :description

  property :script

  property :tags

  property :job_schedules

  def tags
    model.tags.pluck(:name)
  end

  def job_schedules
    model.job_schedules.pluck(:cron)
  end

  delegate :id, :name, :description, :script, :destroy, to: :model
end
