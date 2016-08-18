module Kuroko2
  class Engine < ::Rails::Engine
    isolate_namespace Kuroko2

    config.before_configuration do
      require 'kaminari'
      require 'chrono'
    end

    config.autoload_paths << root.join('lib')

    initializer "kuroko2.configuration" do |app|
      URI.parse(Kuroko2.config.url).tap do |url|
        Kuroko2.config.url_host   = url.host
        Kuroko2.config.url_scheme = url.scheme
        Kuroko2.config.url_port   = url.port
      end

      if Kuroko2.config.custom_tasks
        Kuroko2.config.custom_tasks.each do |key, klass|
          unless Workflow::Node::TASK_REGISTORY.has_key?(key)
            Workflow::Node.register(
              key: key.to_sym,
              klass: Workflow::Task.const_get(klass, false)
            )
          end
        end
      end

      config.action_mailer.default_url_options = {
        host:     Kuroko2.config.url_host,
        protocol: Kuroko2.config.url_scheme,
        port:     Kuroko2.config.url_port
      }

      config.action_mailer.delivery_method = Kuroko2.config.action_mailer.delivery_method.to_sym
      config.action_mailer.smtp_settings =
        Kuroko2.config.action_mailer.smtp_settings.to_h.symbolize_keys || {}
    end
  end
end
