class Kuroko2::SessionsController < Kuroko2::ApplicationController
  skip_before_action :require_sign_in

  def new
    render layout: false
  end

  def create
    return_to = params[:state]
    reset_session

    unless valid_google_hosted_domain?
      render :invalid_hd, status: 403, layout: false
      return
    end

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

  def valid_google_hosted_domain?
    options = Kuroko2.config.app_authentication.google_oauth2.options
    hd = options ? options.hd : nil
    if hd.present?
      hd == auth_hash.extra.id_info.hd
    else
      true
    end
  end
end
