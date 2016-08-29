class HelloController < ApplicationController

  skip_before_action :require_sign_in

  def revision
    render plain: REVISION
  end
end
