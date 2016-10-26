require 'kuroko2'
require 'serverengine'

module Kuroko2
  module Servers
    class Base
      if Rails.env.development?
        ActionMailer::Base.logger = Kuroko2.logger
      end

      def initialize(options = {})
        @options = options
      end

      def run
        ServerEngine.create(nil, worker, default_options.merge(@options)).run
      end

      private

      def worker
        raise NotImplementedError
      end

      def default_options
        {}
      end
    end
  end
end
