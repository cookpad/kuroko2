class Kuroko2::HelloController < Kuroko2::ApplicationController

  skip_before_action :require_sign_in

  def revision
    render plain: REVISION
  end
end
