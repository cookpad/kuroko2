config = Kuroko2.config.app_authentication.try!(:google_oauth2)
if config.present?
  require 'omniauth-google-oauth2'
  Rails.application.config.middleware.use OmniAuth::Builder do
    provider :google_oauth2, config.client_id, config.client_secret, options
  end
end
