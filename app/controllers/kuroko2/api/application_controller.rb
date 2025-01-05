class Kuroko2::Api::ApplicationController < ActionController::API
  include ActionController::HttpAuthentication::Basic::ControllerMethods
  include Garage::ControllerHelper

  before_action :api_authentication

  rescue_from ActiveRecord::RecordNotFound do |exception|
    respond_with_error(404, 'record_not_found', exception.message)
  end

  rescue_from Http::Forbidden do |exception|
    respond_with_error(403, 'forbidden', exception.message)
  end

  rescue_from Http::Unauthorized do |exception|
    respond_with_error(401, 'unauthorized', exception.message)
  end

  rescue_from Http::UnprocessableEntity do |exception|
    respond_with_error(422, 'unprocessable_entity', exception.message)
  end

  rescue_from WeakParameters::ValidationError do |exception|
    respond_with_error(400, 'bad_request', exception.message)
  end

  private

  # @param [Integer] status_code HTTP status code
  # @param [String] error_code Must be unique
  # @param [String] message Error message for API client, not for end user.
  def respond_with_error(status_code, error_code, message)
    render json: { status_code: status_code, error_code: error_code, message: message }, status: status_code
  end

  def api_authentication
    service_name = authenticate_with_http_basic do |name, api_key|
      stored = Kuroko2.config.api_basic_authentication_applications.try!(name.to_sym)
      if stored && Rack::Utils.secure_compare(api_key, stored)
        name.to_sym
      else
        nil
      end
    end

    if service_name.nil?
      raise Http::Unauthorized
    end
  end

  def basic_user_name
    ActionController::HttpAuthentication::Basic.user_name_and_password(request).first
  end
end
