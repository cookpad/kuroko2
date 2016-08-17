module Util
  class RailsLoggerFormatter < ::Logger::Formatter
    def call(severity, timestamp, _, msg)
      "%s %-5s: %s\n" % [timestamp.iso8601, severity, msg]
    end
  end
end
