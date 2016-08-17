require 'kuroko2/configuration'

module Kuroko2
  class Engine < ::Rails::Engine
    isolate_namespace Kuroko2

    config.before_configuration do
      require 'kaminari'
      require 'chrono'
    end

    config.autoload_paths << root.join('lib')

    kuroko2_config = Kuroko2::Configuration.config

    URI.parse(kuroko2_config.url).tap do |url|
      kuroko2_config.url_host   = url.host
      kuroko2_config.url_scheme = url.scheme
      kuroko2_config.url_port   = url.port
    end

    if kuroko2_config.custom_tasks
      kuroko2_config.custom_tasks.each do |key, klass|
        unless Workflow::Node::TASK_REGISTORY.has_key?(key)
          Workflow::Node.register(
            key: key.to_sym,
            klass: Workflow::Task.const_get(klass, false)
          )
        end
      end
    end

    Kuroko2::Engine.config.action_mailer.default_url_options = {
      host:     kuroko2_config.url_host,
      protocol: kuroko2_config.url_scheme,
      port:     kuroko2_config.url_port
    }

    config.action_mailer.delivery_method = kuroko2_config.action_mailer.delivery_method.to_sym
    config.action_mailer.smtp_settings =
      kuroko2_config.action_mailer.smtp_settings.to_h.symbolize_keys || {}
  end
end
