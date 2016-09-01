module CustomController
  extend ActiveSupport::Concern
  included do
    before_action :additional_before_action
  end

  private

  def additional_before_action
    if signed_in?
      # do something
    end
  end
end
