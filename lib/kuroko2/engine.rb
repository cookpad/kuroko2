module Kuroko2
  class Engine < ::Rails::Engine
    isolate_namespace Kuroko2

    config.before_configuration do
      require 'kaminari'
      require 'slim'
      require 'jbuilder'
      require 'garage'
      require 'jquery-rails'
      require 'momentjs-rails'
      require 'rails_bootstrap_sortable'
      require 'select2-rails'
      require 'font-awesome-rails'
      require 'visjs/rails'
      require 'dotenv-rails'
      require 'weak_parameters'
    end

    config.autoload_paths << root.join('lib/autoload').to_s
    config.eager_load_paths << root.join('lib/autoload').to_s

    initializer "kuroko2.configuration" do |app|
      URI.parse(Kuroko2.config.url).tap do |url|
        Kuroko2.config.url_host   = url.host
        Kuroko2.config.url_scheme = url.scheme
        Kuroko2.config.url_port   = url.port
      end

      config.active_record.table_name_prefix = Kuroko2.config.table_name_prefix

      if Kuroko2.config.custom_tasks
        Kuroko2.config.custom_tasks.each do |key, klass|
          unless Workflow::Node::TASK_REGISTRY.has_key?(key)
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

      app.config.assets.precompile += %w(kuroko2/kuroko-logo-success.png kuroko2/kuroko-logo-error.png)

      if Kuroko2.config.extensions && Kuroko2.config.extensions.controller
        Kuroko2.config.extensions.controller.each do |extension|
          Kuroko2::ApplicationController.include(Object.const_get(extension, false))
        end
      elsif Kuroko2.config.extentions && Kuroko2.config.extentions.controller
        # XXX: Check legacy configuration which was typo
        Kuroko2.config.extentions.controller.each do |extention|
          Kuroko2::ApplicationController.include(Object.const_get(extention, false))
        end
      end
    end
  end
end
