class Api::JobInstanceResource < Api::ApplicationResource
  property :id

  property :status

  delegate :id, :status, to: :model
end
