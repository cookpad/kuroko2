module CustomController
  extend ActiveSupport::Concern
  included do
    before_action :hoge
  end

  private

  def hoge
  end
end
