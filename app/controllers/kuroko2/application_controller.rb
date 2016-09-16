class Kuroko2::ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :current_user, :signed_in?
  before_action :require_sign_in

  rescue_from HTTP::BadRequest do
    respond_to do |format|
      format.html { render 'public/500.html', layout: false, status: :bad_request }
      format.json { render json: { message: 'Bad Request' }, status: :bad_request }
    end
  end

  def current_user
    @_current_user ||= begin
      if (id = session[:user_id])
        Kuroko2::User.active.find(id)
      end
    end
  rescue ActiveRecord::RecordNotFound
    reset_session
    redirect_to sign_in_path(return_to: url_for(params.merge(only_path: true)))
  end

  private

  def current_user=(user)
    session[:user_id] = user.id
    @_current_user    = user
  end

  def signed_in?
    current_user.present?
  end

  def require_sign_in
    unless signed_in?
      redirect_to sign_in_path(return_to: url_for(params.permit!.to_h.merge(only_path: true)))
    end
  end
end
