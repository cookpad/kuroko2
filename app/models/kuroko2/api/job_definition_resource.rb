class Kuroko2::Api::JobDefinitionResource < Kuroko2::Api::ApplicationResource
  property :id

  property :name

  property :description

  property :script

  delegate :id, :name, :description, :script, to: :model
end
