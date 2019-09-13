class Kuroko2::Api::JobDefinitionResource < Kuroko2::Api::ApplicationResource
  property :id

  property :name

  property :description

  property :script

  property :tags

  property :cron

  def tags
    model.tags.map(&:name)
  end

  def cron
    model.job_schedules.map(&:cron)
  end

  delegate :id, :name, :description, :script, :destroy, to: :model
end
