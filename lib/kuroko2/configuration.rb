require 'hashie'

module Kuroko2
  class Configuration
    class << self
      DEFAULT_CONFIG = { table_name_prefix: 'kuroko2_' }.freeze

      def config
        @config ||= build_config
      end

      def build_config
        filename = Rails.root.join('config', 'kuroko2.yml')
        yaml = YAML::load(ERB.new(File.read(filename)).result)
        Hashie::Mash.new(DEFAULT_CONFIG.merge(yaml[Rails.env]))
      end
    end
  end
end
