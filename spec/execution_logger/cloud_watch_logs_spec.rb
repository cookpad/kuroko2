require 'rails_helper'

describe Kuroko2::ExecutionLogger::CloudWatchLogs do
  let(:stream_name) { 'test' }
  let(:object) { described_class.new(stream_name: stream_name, group_name: 'kuroko') }

  before do
    allow(Aws::CloudWatchLogs::Client).to receive(:new).and_return(double('CloudWatchLogsClient'))
  end

  describe '#put_logs' do
    let(:events) { [{ timestamp: Time.current.to_i * 1000, message: 'hello' }] }
    let(:response) { double('Response', data: { next_sequence_token: 'abc' })}

    let(:send_parameters) do
      {
        log_group_name: 'kuroko',
        log_stream_name: stream_name,
        log_events: events,
        sequence_token: nil,
      }
    end

    it "sends logs to cloud watch logs" do
      expect(object.client).to receive(:put_log_events).
        with(send_parameters).and_return(response)
      expect(object.put_logs(events)).to eq(response)
    end

    context 'when token is invalid' do
      before do
        exception = Aws::CloudWatchLogs::Errors::InvalidSequenceTokenException.new(
          '',
          'The given sequenceToken is invalid. The next expected sequenceToken is: xxxx',
        )

        allow(object.client).to receive(:put_log_events).
          with(send_parameters).and_raise(exception)
      end

      it 'gets token from the error message and retry' do
        expect(object.client).to receive(:put_log_events).with(
          log_group_name: 'kuroko',
          log_stream_name: stream_name,
          log_events: events,
          sequence_token: 'xxxx',
        ).and_return(response)

        expect(object.put_logs(events)).to eq(response)
      end
    end

    context 'when the stream is not created' do
      before do
        exception = Aws::CloudWatchLogs::Errors::ResourceNotFoundException.new('', '')
        allow(object.client).to receive(:put_log_events).
          with(send_parameters).and_raise(exception)
      end

      it 'creates the stream' do
        expect(object.client).to receive(:create_log_stream).with(
          log_group_name: 'kuroko',
          log_stream_name: stream_name,
        ) do
          allow(object.client).to receive(:put_log_events).with(send_parameters).
            and_return(response)
        end

        expect(object.put_logs(events)).to eq(response)
      end
    end
  end

  describe '#get_logs' do
    let(:next_token) { 'next_token' }
    let(:response) { double('Response', next_forward_token: next_token)}
    let(:response2) { double('Response', next_forward_token: 'next_token2')}

    it "gets logs" do
      expect(object.client).to receive(:get_log_events).with({
        log_group_name: 'kuroko',
        log_stream_name: stream_name,
        next_token: nil,
        start_from_head: true,
      }).and_return(response)

      expect(object.get_logs).to eq(response)

      expect(object.client).to receive(:get_log_events).with({
        log_group_name: 'kuroko',
        log_stream_name: stream_name,
        next_token: next_token,
        start_from_head: true,
      }).and_return(response2)

      expect(object.get_logs).to eq(response2)
    end
  end
end
