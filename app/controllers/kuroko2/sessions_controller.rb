class Kuroko2::SessionsController < Kuroko2::ApplicationController
  skip_before_action :require_sign_in

  def new
    render layout: false
  end

  def create
    return_to = params[:state]
    reset_session

    self.current_user = Kuroko2::User.find_or_create_user(auth_hash[:uid], auth_hash[:info])

    unless Kuroko2::ReturnToValidator.valid?(return_to)
      return_to = root_path
    end
    redirect_to return_to
  end

  def destroy
    reset_session

    redirect_to sign_in_path
  end

  private

  def auth_hash
    request.env['omniauth.auth']
  end

end
