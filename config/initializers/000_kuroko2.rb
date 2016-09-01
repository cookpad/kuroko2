URI.parse(Kuroko2.config.url).tap do |url|
  Kuroko2.config.url_host   = url.host
  Kuroko2.config.url_scheme = url.scheme
  Kuroko2.config.url_port   = url.port
end

Rails.application.config.action_mailer.default_url_options = {
  host:     Kuroko2.config.url_host,
  protocol: Kuroko2.config.url_scheme,
  port:     Kuroko2.config.url_port
}

Rails.application.config.action_mailer.delivery_method =
  Kuroko2.config.action_mailer.delivery_method.to_sym
Rails.application.config.action_mailer.smtp_settings =
  Kuroko2.config.action_mailer.smtp_settings.to_h.symbolize_keys || {}
