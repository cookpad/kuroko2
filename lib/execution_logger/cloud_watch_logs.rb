class ExecutionLogger::CloudWatchLogs
  MAX_RETRY_COUNT = 5
  RETRY_ERRORS = [
    Aws::CloudWatchLogs::Errors::InvalidSequenceTokenException,
    Aws::CloudWatchLogs::Errors::ThrottlingException,
    Aws::CloudWatchLogs::Errors::ResourceNotFoundException,
  ]

  attr_reader :client

  def initialize(stream_name:, group_name:, region: 'ap-northeast-1')
    @client = Aws::CloudWatchLogs::Client.new(region: region)

    @group_name    = group_name
    @stream_name   = stream_name
    @put_log_token = nil
    @get_log_token = nil
  end

  def send_log(message)
    put_logs([{ timestamp: timestamp_now, message: message.to_json }])
  end

  def put_logs(events)
    exception_cb = lambda do |exception|
      case exception
      when Aws::CloudWatchLogs::Errors::InvalidSequenceTokenException
        @put_log_token = exception.message.match(%r{\AThe given sequenceToken is invalid. The next expected sequenceToken is:\s*(\w+)\z})[1]
      when Aws::CloudWatchLogs::Errors::ResourceNotFoundException
        create_log_stream
      when Aws::CloudWatchLogs::Errors::ThrottlingException
        sleep(0.5)
      end
    end

    retry_options = {
      exception_cb: exception_cb,
      on: RETRY_ERRORS,
      tries: MAX_RETRY_COUNT,
      sleep: 0,
    }

    Retryable.retryable(retry_options) do
      response = client.put_log_events(
        log_group_name: @group_name,
        log_stream_name: @stream_name,
        log_events: events,
        sequence_token: @put_log_token,
      )
      @put_log_token = response.data[:next_sequence_token]

      response
    end
  end

  def get_logs(token = @get_log_token)
    response = client.get_log_events({
      log_group_name: @group_name,
      log_stream_name: @stream_name,
      next_token: token,
      start_from_head: true,
    })

    @get_log_token = response.next_forward_token
    response
  rescue Aws::CloudWatchLogs::Errors::ResourceNotFoundException
    raise ExecutionLogger::NotFound
  end

  private

  def timestamp_now
    (Time.now.to_f * 1000).to_i # milliseconds
  end

  def create_log_stream
    client.create_log_stream(log_group_name: @group_name, log_stream_name: @stream_name)
  rescue Aws::CloudWatchLogs::Errors::ResourceAlreadyExistsException
    warn "Log stream '#{@stream_name}' already exists"
  end
end
