require 'rails_helper'

module Kuroko2::Workflow
  describe Notifier::Slack do
    let(:job_name) { 'My Job' }
    let(:slack_channel) { '#dummy' }
    let(:instance) do
      create(:job_definition_with_instances, name: job_name, slack_channel: slack_channel).
        job_instances.first
    end

    let(:notifier) { Notifier::Slack.new(instance) }
    let(:endpoint) { Kuroko2.config.notifiers.slack.webhook_url }
    let(:response) { { body: 'ok' } }

    before do
      instance.logs.info('start!')

      stub_request(:post, endpoint).with(
        headers: { "Content-Type" => 'application/json' },
      ).and_return(response)
    end

    describe '#notify_failure' do
      it 'sends failure mesasge' do
        expect(notifier).to receive(:send_to_slack).
          with(hash_including(channel: slack_channel)).and_call_original

        notifier.notify_failure
      end

      context 'with additional_text' do
        let(:additional_text) { '@eisuke-oishi' }
        before do
          instance.job_definition.hipchat_additional_text = additional_text
          instance.save!
        end

        it 'sends additional message' do
          expect(notifier).to receive(:send_additional_text_to_slack).once.and_call_original
          notifier.notify_failure
        end
      end
    end

    describe '#notify_cancellation' do
      before do
        instance.job_definition.notify_cancellation = true
        instance.save!
      end

      it 'sends cancellation mesasge' do
        expect(notifier).to receive(:send_to_slack).
          with(hash_including(channel: slack_channel)).and_call_original

        notifier.notify_cancellation
      end
    end

    describe '#notify_critical' do
      it 'sends critical mesasge' do
        expect(notifier).to receive(:send_to_slack).
          with(hash_including(channel: slack_channel)).and_call_original

        notifier.notify_critical
      end

      context 'with additional_text' do
        let(:additional_text) { '@eisuke-oishi' }

        before do
          instance.job_definition.hipchat_additional_text = additional_text
          instance.save!
        end

        it 'sends additional message' do
          expect(notifier).to receive(:send_additional_text_to_slack).and_call_original
          notifier.notify_failure
        end
      end
    end

    describe '#notify_finished' do
      it 'sends finished mesasge' do
        expect(notifier).to receive(:send_to_slack).
          with(hash_including(channel: slack_channel)).and_call_original

        notifier.notify_finished
      end
    end

    describe '#notify_retrying' do
      context 'with notify_finished' do
        before do
          instance.job_definition.hipchat_notify_finished = true
          instance.save!
        end

        it 'sends retrying mesasge' do
          expect(notifier).to receive(:send_to_slack).
            with(hash_including(channel: slack_channel)).and_call_original

          notifier.notify_retrying
        end
      end

      context 'without notify_finished' do
        before do
          instance.job_definition.hipchat_notify_finished = false
          instance.save!
        end

        it 'sends retrying mesasge' do
          expect(notifier).not_to receive(:send_to_slack)
          notifier.notify_retrying
        end
      end
    end

    describe '#notify_skipping' do
      context 'with notify_finished' do
        before do
          instance.job_definition.hipchat_notify_finished = true
          instance.save!
        end

        it 'sends skipping mesasge' do
          expect(notifier).to receive(:send_to_slack).
            with(hash_including(channel: slack_channel)).and_call_original

          notifier.notify_skipping
        end
      end

      context 'without notify_finished' do
        before do
          instance.job_definition.hipchat_notify_finished = false
          instance.save!
        end

        it 'sends skipping mesasge' do
          expect(notifier).not_to receive(:send_to_slack)
          notifier.notify_skipping
        end
      end
    end

    describe '#notify_launch' do
      context 'with notify_finished' do
        before do
          instance.job_definition.hipchat_notify_finished = true
          instance.save!
        end

        it 'sends launch mesasge' do
          expect(notifier).to receive(:send_to_slack).
            with(hash_including(channel: slack_channel)).and_call_original

          notifier.notify_launch
        end
      end

      context 'without notify_finished' do
        before do
          instance.job_definition.hipchat_notify_finished = false
          instance.save!
        end

        it 'sends launch mesasge' do
          expect(notifier).not_to receive(:send_to_slack)
          notifier.notify_launch
        end
      end
    end

    describe '#notify_long_elapsed_time' do
      it 'sends warning mesasge' do
        expect(notifier).to receive(:send_to_slack).
          with(hash_including(channel: slack_channel)).and_call_original

        notifier.notify_long_elapsed_time
      end
    end

    context 'with invalid response' do
      let(:response) { { status: 500 } }

      it 'logs to response' do
        expect(Kuroko2.logger).to receive(:fatal).with(/Failure sending message/)
        notifier.notify_failure
      end
    end
  end
end
