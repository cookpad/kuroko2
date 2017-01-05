require 'hashie'

module Kuroko2
  class Configuration
    class << self
      DEFAULT_CONFIG = { table_name_prefix: 'kuroko2_' }.freeze

      def config
        @config ||= build_config
      end

      private

      def build_config
        Hashie::Mash.new(DEFAULT_CONFIG.merge(Rails.application.config_for('kuroko2')))
      end
    end
  end
end
