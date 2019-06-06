class Kuroko2::Api::JobDefinitionResource < Kuroko2::Api::ApplicationResource
  property :id

  property :name

  property :description

  property :script

  property :tags

  def tags
    model.tags.pluck(:name)
  end

  delegate :id, :name, :description, :script, :destroy, to: :model
end
