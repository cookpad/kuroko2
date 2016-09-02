require 'open3'
module Kuroko2
  module Command
    class Shell
      MAX_OUTPUT_LENGTH = 60_000
      MAX_READ_LENGTH   = 1024

      def initialize(hostname:, worker_id: 0, worker:, queue: Execution::DEFAULT_QUEUE)
        @hostname  = hostname
        @worker_id = worker_id
        @worker    = worker
        @queue     = queue
      end

      def execute
        @worker.reload
        unless @worker.execution_id?
          if (execution = Execution.poll(@queue))
            do_execute(execution)
            execution
          end
        end
      rescue RuntimeError => e
        Kuroko2.logger.error("[#{@hostname}-#{@worker_id}] #{e.message}\n" +
          e.backtrace.map { |trace| "[#{@hostname}-#{@worker_id}]    #{trace}" }.join("\n"))

        nil
      end

      private

      def do_execute(execution)
        begin
          @worker.update_column(:execution_id, execution.id)

          invoke(execution)
        rescue SystemCallError => e
          message = "[#{@hostname}-#{@worker_id}] (uuid #{execution.uuid}) `#{execution.shell}` failed because #{e.class}: #{e.message}"
          execution.token.job_instance.logs.warn(message)
          Kuroko2.logger.warn(message)

          output = truncate_and_escape(e.message)
          execution.finish(output: output, exit_status: e.errno)
        ensure
          @worker.update_column(:execution_id, nil)
        end
      end

      def invoke(execution)
        command = execution.shell
        env     = execution.context.fetch('ENV', {})

        message = "[#{@hostname}-#{@worker_id}] (uuid #{execution.uuid}) `#{command}` run with env (#{env})"
        execution.token.job_instance.logs.info(message)
        Kuroko2.logger.info(message)

        output, status = execute_shell(command, env, execution)
        output         = truncate_and_escape(output)

        if status.signaled?
          message = "[#{@hostname}-#{@worker_id}] (uuid #{execution.uuid}) `#{command}` stopped by #{Signal.signame(status.termsig)} signal (pid #{status.pid})"
          execution.token.job_instance.logs.warn(message)
          Kuroko2.logger.warn(message)

          execution.finish_by_signal(output: output, term_signal: status.termsig)
        else
          message = "[#{@hostname}-#{@worker_id}] (uuid #{execution.uuid}) `#{command}` finished with #{status.exitstatus} (pid #{status.pid})"
          execution.token.job_instance.logs.info(message)
          Kuroko2.logger.info(message)

          execution.finish(output: output, exit_status: status.exitstatus)
        end
      end

      def execute_shell(command, env, execution)
        opts = { unsetenv_others: true, pgroup: true }
        opts[:chdir] = real_path(execution.context['CHDIR']) if execution.context['CHDIR']

        launched_time       = execution.context['meta'].try(:[], 'launched_time').to_s
        job_definition_id   = execution.context['meta'].try(:[], 'job_definition_id').to_s
        job_definition_name = execution.context['meta'].try(:[], 'job_definition_name').to_s
        job_instance_id     = execution.context['meta'].try(:[], 'job_instance_id').to_s

        env.reverse_merge!(
          'HOME'                        => ENV['HOME'],
          'PATH'                        => ENV['PATH'],
          'LANG'                        => ENV['LANG'],
          'KUROKO2_LAUNCHED_TIME'       => launched_time,
          'KUROKO2_JOB_DEFINITION_ID'   => job_definition_id,
          'KUROKO2_JOB_DEFINITION_NAME' => job_definition_name,
          'KUROKO2_JOB_INSTANCE_ID'     => job_instance_id,
        )

        execution_logger = ExecutionLogger.get_logger(
          stream_name: "JOB#{sprintf("%010d", job_definition_id.to_i)}/#{execution.token.job_instance.id}",
        )

        temporally_path_with(env['PATH']) do
          Open3.popen2e(env, command, opts) do |stdin, stdout_and_stderr, thread|
            stdin.close

            pid = thread.pid
            execution.update_attributes(pid: pid)

            reader = Thread.new do
              begin
                output = ''
                stdout_and_stderr.each do |data|
                  output << data
                  execution_logger.send_log(
                    {
                      uuid: execution.uuid,
                      pid: pid,
                      level: 'NOTICE',
                      message: truncate_and_escape(data.chomp),
                    }
                  )
                end
              rescue EOFError
                # do nothing
              rescue => e
                warn e
              ensure
                next output
              end
            end

            status = thread.value # wait until thread is dead
            output = reader.value

            [output, status]
          end
        end
      end

      def real_path(path)
        path = Pathname.new(path.sub(/\/\Z/, ''))
        Retryable.retryable(tries: 3, sleep: 0.5, on: [Errno::ENOENT]) do
          path.realpath
        end
      end

      def temporally_path_with(path)
        original_path = ENV['PATH']

        ENV['PATH'] = path
        yield
      ensure
        ENV['PATH'] = original_path
      end

      def truncate_and_escape(str)
        str.force_encoding('utf-8')
        truncated = str.length > MAX_OUTPUT_LENGTH ? str[0...MAX_OUTPUT_LENGTH] : str
        truncated.scrub.each_char.select{ |c| c.bytes.count < 4 }.join('')
      end
    end
  end
end
