class Kuroko2::Api::JobInstanceResource < Kuroko2::Api::ApplicationResource
  property :id

  property :status

  delegate :id, :status, to: :model
end
