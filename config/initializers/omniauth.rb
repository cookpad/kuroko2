require 'omniauth-google-oauth2'

Rails.application.config.middleware.use OmniAuth::Builder do
  opts = {
    setup: (
      lambda do |env|
        env['omniauth.strategy'].options['token_params'] = {
          redirect_uri: "http://localhost:3000/auth/google_oauth2/callback"
        }
      end
    )
  }

  if ENV.has_key?('GOOGLE_HOSTED_DOMAIN')
    opts[:hd] = ENV['GOOGLE_HOSTED_DOMAIN']
  end

  provider :google_oauth2, ENV["GOOGLE_CLIENT_ID"], ENV["GOOGLE_CLIENT_SECRET"], opts
end
