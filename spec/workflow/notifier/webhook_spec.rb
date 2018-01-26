require 'rails_helper'

module Kuroko2::Workflow
  describe Notifier::Webhook do
    let(:job_name) { 'My Job' }
    let(:slack_channel) { '#dummy' }
    let(:webhook_url) { 'https://localhost/my/hook_point' }
    let(:instance) do
      create(:job_definition_with_instances, name: job_name, webhook_url: webhook_url).
        job_instances.first
    end

    let(:notifier) { Notifier::Webhook.new(instance) }
    let(:response) { { body: 'ok' } }
    let(:stub) do
      stub_request(:post, webhook_url).and_return(response)
    end

    before do
      instance.logs.info('start!')
    end

    describe '#notify_failure' do
      it 'sends failure mesasge' do
        stub.with { |req|
          expect(req.headers['X-Kuroko2-Id']).to be_present
          expect(req.headers['X-Kuroko2-Signature']).to be_present
          expect(JSON.parse(req.body)).to include("action"=>"notify_failure")
        }

        notifier.notify_failure
        expect(stub).to have_been_requested
      end
    end

    describe '#notify_cancellation' do
      before do
        instance.logs.warn('warn')
        instance.job_definition.notify_cancellation = true
        instance.save!
      end

      it 'sends cancellation mesasge' do
        stub.with { |req|
          expect(JSON.parse(req.body)).to include("action"=>"notify_cancellation")
        }

        notifier.notify_cancellation
        expect(stub).to have_been_requested
      end
    end

    describe '#notify_critical' do
      it 'sends critical mesasge' do
        stub.with { |req|
          expect(JSON.parse(req.body)).to include("action"=>"notify_critical")
        }

        notifier.notify_critical
        expect(stub).to have_been_requested
      end
   end

    describe '#notify_finished' do
      it 'sends finished mesasge' do
        stub.with { |req|
          expect(JSON.parse(req.body)).to include("action"=>"notify_finished")
        }

        notifier.notify_finished
        expect(stub).to have_been_requested
      end
    end

    describe '#notify_back_to_normal' do
      it 'sends back_to_normal message' do
        stub.with { |req|
          expect(JSON.parse(req.body)).to include("action"=>"notify_back_to_normal")
        }

        notifier.notify_back_to_normal
        expect(stub).to have_been_requested
      end
    end

    describe '#notify_retrying' do
      context 'with notify_finished' do
        before do
          instance.job_definition.hipchat_notify_finished = true
          instance.save!
        end

        it 'sends retrying mesasge' do
          stub.with { |req|
            expect(JSON.parse(req.body)).to include("action"=>"notify_retrying")
          }

          notifier.notify_retrying
          expect(stub).to have_been_requested
        end
      end

      context 'without notify_finished' do
        before do
          instance.job_definition.hipchat_notify_finished = false
          instance.save!
        end

        it 'sends retrying mesasge' do
          notifier.notify_retrying
          expect(stub).not_to have_been_requested
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
          stub.with { |req|
            expect(JSON.parse(req.body)).to include("action"=>"notify_skipping")
          }

          notifier.notify_skipping
          expect(stub).to have_been_requested
        end
      end

      context 'without notify_finished' do
        before do
          instance.job_definition.hipchat_notify_finished = false
          instance.save!
        end

        it 'sends skipping mesasge' do
          notifier.notify_skipping
          expect(stub).not_to have_been_requested
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
          stub.with { |req|
            expect(JSON.parse(req.body)).to include("action"=>"notify_launch")
          }

          notifier.notify_launch
          expect(stub).to have_been_requested
        end
      end

      context 'without notify_finished' do
        before do
          instance.job_definition.hipchat_notify_finished = false
          instance.save!
        end

        it 'sends launch mesasge' do
          notifier.notify_launch
          expect(stub).not_to have_been_requested
        end
      end
    end

    describe '#notify_long_elapsed_time' do
      it 'sends warning mesasge' do
        stub.with { |req|
          expect(JSON.parse(req.body)).to include("action"=>"notify_long_elapsed_time")
        }

        notifier.notify_long_elapsed_time
        expect(stub).to have_been_requested
      end
    end

    context 'with invalid response' do
      let(:response) { { status: 500 } }

      it 'logs to response' do
        stub
        expect(Kuroko2.logger).to receive(:fatal).with(/Failure sending webhook/)
        notifier.notify_failure
        expect(stub).to have_been_requested
      end
    end
  end
end
