class Api::ApplicationResource
  include Garage::Representer
  include Garage::Authorizable

  attr_reader :model

  def initialize(model = nil)
    @model = model
  end
end
