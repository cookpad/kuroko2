require 'open3'

module Command
  class Monitor
    NUM_FAILURES = 15

    def initialize(hostname:, worker_id:)
      @hostname  = hostname
      @worker_id = worker_id
      @counter   = Hash.new(0)
      @intervals = {}
    end

    def execute
      execution_ids = Worker.on(@hostname).pluck(:execution_id).compact
      executions = Execution.where(id: execution_ids, mailed_at: nil).started
      executions.each do |execution|
        if execution.pid
          if check_process_absence(execution) && log_memory_consumption?(execution)
            get_memory_consumption(execution).try do |value|
              execution.log_memory_consumption(value)
            end
          end
        else
          check_assignment_delay(execution)
        end
      end

      (@counter.keys - executions.map(&:id)).each do |removable_id|
        @counter.delete(removable_id)
      end
    end

    def counter_size
      @counter.size
    end

    private

    # @return [Boolean] true means process is exists
    def check_process_absence(execution)
      begin
        process_num = Process.kill(0, execution.pid)
        @counter.delete(execution.id)
        !!process_num
      rescue Errno::EPERM
        true
      rescue Errno::ESRCH
        if Execution.exists?(execution.id)
          @counter[execution.id] += 1

          message = "(execution.id #{execution.id}) : PID #{execution.pid} not found, increment monitor counter to #{@counter[execution.id]}."
          Kuroko2.logger.info { message }
          Kuroko2.logger.info(@counter) # TODO: will remove this logging (for debug only).

          if @counter[execution.id] >= NUM_FAILURES
            notify_process_absence(execution)
            @counter.delete(execution.id)
            @intervals.delete(execution.id)
          end
        else
          @counter.delete(execution.id)
          @intervals.delete(execution.id)
        end
        false
      end
    end

    def log_memory_consumption?(execution)
      if @intervals[execution.id]
        @intervals[execution.id].reached?(Time.now)
      else # first time
        @intervals[execution.id] = MemoryConsumptionLog::Interval.new(Time.now)
        true
      end
    end

    def get_memory_consumption(execution)
      result = MemorySampler.get_by_pgid(execution.pid)
      if result
        @intervals[execution.id] = @intervals[execution.id].next
        result
      else
        nil
      end
    end

    def notify_process_absence(execution)
      message = "(execution #{execution.uuid}) Deliver notification mail: PID #{execution.pid} is not running."
      Kuroko2.logger.info { message }
      execution.job_instance.logs.warn(message)

      Notifications.process_absence(execution, @hostname).deliver_now
      execution.touch(:mailed_at)
    end

    def check_assignment_delay(execution)
      if execution.started_at < 1.minutes.ago
        message = "(execution #{execution.uuid}) Deliver notification mail: process is not assigned to any job-executor."
        Kuroko2.logger.info { message }
        execution.job_instance.logs.warn(message)

        Notifications.executor_not_assigned(execution, @hostname).deliver_now
        execution.touch(:mailed_at)
      end
    end
  end
end
