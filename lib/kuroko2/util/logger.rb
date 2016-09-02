module Util
  class Logger < ::Logger
    def initialize(*args)
      super

      @formatter = LoggerFormatter.new
    end

    class LoggerFormatter < ::Logger::Formatter
      def call(severity, timestamp, progname, msg)
        location = caller_locations(4, 1).first

        "%s %-5s - %s: %s\n" % [timestamp.iso8601, severity, location.label, msg]
      end
    end
  end
end
