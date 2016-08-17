require 'hashie'

module Kuroko2
  class Configuration
    class << self
      def config
        @config ||= build_config
      end

      def build_config
        filename = defined?(Rails) && Rails.root ?
          Rails.root.join('config', 'settings.yml') :
          Kuroko2::Engine.root.join('config/default_settings.yml')

        yaml = YAML::load(ERB.new(File.read(filename)).result)
        Hashie::Mash.new(yaml[Rails.env])
      end
    end
  end
end
