class MemoryConsumptionLog < ActiveRecord::Base
  belongs_to :job_instance

  validates :value, presence: true

  # As count becames greater, the interval period will be longer.
  # First interval will be 1 second and next interval will be 1 second too,
  # then next interval will be 4 seconds then next interval will be 9 seconds.
  # Finally, maximum of interval will be 30 minutes.
  class Interval
    INITIAL_INTERVAL_PERIOD = 1.second.to_i
    MAX_INTERVAL_PERIOD = 30.minutes.to_i
    INCREMENT = 2

    attr_reader :base_time, :count

    # @param [Time] base_time
    # @param [Integer] count Throttled to be less than 50.
    def initialize(base_time, count = 0)
      @base_time = base_time
      @count = [count, 50].min
    end

    # @param [Time] now
    # @return [Boolean]
    def reached?(now)
      (now - @base_time) > current_length
    end

    # @return [MemoryConsumptionLog::Interval]
    def next
      self.class.new(Time.at(@base_time.to_i + current_length), @count.succ)
    end

    private

    # current_length mapping for count (0..50)
    #
    # [1, 1, 4, 9, 16, 25, 36, 49, 64, 81, 100, 121, 144, 169, 196, 225, 256,
    #  289, 324, 361, 400, 441, 484, 529, 576, 625, 676, 729, 784, 841, 900,
    #  961, 1024, 1089, 1156, 1225, 1296, 1369, 1444, 1521, 1600, 1681, 1764,
    #  1800, 1800, 1800, 1800, 1800, 1800, 1800, 1800]
    def current_length
      [[@count ** INCREMENT, INITIAL_INTERVAL_PERIOD].max, MAX_INTERVAL_PERIOD].min
    end
  end
end
