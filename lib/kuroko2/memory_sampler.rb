require 'open3'
module Kuroko2
  module MemorySampler
    extend self

    # @param [Integer] pgid process group id
    # @return [Integer] sum of memory consumptions of given process group
    def get_by_pgid(pgid)
      case platform
      when /linux/
        get_by_pgid_linux(pgid)
      when /darwin/
        get_by_pgid_osx(pgid)
      else
        raise "Unknown platform: #{platform}"
      end
    rescue SystemCallError
      nil
    end

    private

    # Note:
    #   taiki-ono@ci-slave-ruby-001:~$ ps -o pgid= -o rss=
    #   22848   888
    #   25848  4056
    def get_by_pgid_linux(pgid)
      output, _, status = Open3.capture3('ps', '-o', 'pgid=', '-o', 'rss=')
      if status.success?
        targets = output.split("\n").select {|line| line.split(' ').first == pgid.to_s }
        calculate_sum(targets.map {|line| line.split(' ')[1] })
      else
        nil
      end
    end

    def get_by_pgid_osx(pgid)
      output, _, status = Open3.capture3('ps', '-o' 'rss=', '-g', pgid.to_s)
      status.success? ? calculate_sum(output.split("\n")) : nil
    end

    def calculate_sum(rss_lines)
      rss_lines.reject(&:blank?).map {|s| s.scan(/\d+/).first }.map(&:to_i).reduce(&:+)
    end

    def platform
      RUBY_PLATFORM.downcase
    end
  end
end
