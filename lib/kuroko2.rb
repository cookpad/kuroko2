require "kuroko2/engine"
require 'hashie'

module Kuroko2
  class << self
    def logger
      @logger ||= defined?(Rails) && Rails.env.test? ? Rails.logger : Util::Logger.new($stdout)
    end

    def logger=(logger)
      @logger = logger
    end

    def config
      @config ||= build_config
    end

    def build_config
      filename = defined?(Rails) && Rails.root ?
        File.join(Rails.root, 'config', 'settings.yml') :
        Kuroko2::Engine.root.join('config/default_settings.yml')

      yaml = YAML::load(ERB.new(File.read(filename)).result)
      Hashie::Mash.new(yaml[Rails.env])
    end
  end

  if config.custom_tasks
    config.custom_tasks.each do |key, klass|
      unless Workflow::Node::TASK_REGISTORY.has_key?(key)
        Workflow::Node.register(
          key: key.to_sym,
          klass: Workflow::Task.const_get(klass, false)
        )
      end
    end
  end
end
