require 'rails_helper'

module Kuroko2::Workflow
  describe Notifier::Hipchat do
    let(:job_name) { 'My Job' }
    let(:hipchat_room) { 'dummy' }
    let(:instance) do
      create(:job_definition_with_instances, name: job_name, hipchat_room: hipchat_room).
        job_instances.first
    end

    let(:notifier) { Notifier::Hipchat.new(instance) }
    let(:hipchat_room_object) { double('Hipchat::Room', send: true) }

    before do
      allow(Kuroko2.config.notifiers.hipchat).to receive(:api_token).and_return('token')

      instance.logs.info('start!')
      allow(notifier.hipchat).to receive(:[]).with(hipchat_room).
        and_return(hipchat_room_object)
    end

    describe '#hipchat' do
      it 'is an instance of HipChat::Client' do
        expect(Notifier::Hipchat.new(instance).hipchat).to be_an_instance_of(::HipChat::Client)
      end

      it 'accepts options from conig' do
        options = {
          api_version: 'v2',
          server_url: 'https://api.example.com',
        }

        allow(Kuroko2.config.notifiers.hipchat).to receive(:options).
          and_return(Hashie::Mash.new(options))

        client = class_double(::HipChat::Client).as_stubbed_const
        expect(client).to receive(:new).with('token', options)

        Notifier::Hipchat.new(instance)
      end
    end

    describe '#notify_failure' do
      it 'sends failure mesasge' do
        expect(hipchat_room_object).to receive(:send) do |_, message, option|
          expect(message).to include('FAILURE')
          expect(option[:color]).to eq('red')
        end

        notifier.notify_failure
      end

      context 'with additional_text' do
        let(:additional_text) { '@EisukeOishi' }
        before do
          instance.job_definition.hipchat_additional_text = additional_text
          instance.save!
        end

        it 'sends additional message' do
          expect(hipchat_room_object).to receive(:send) do |_, message, option|
            expect(message).to include('Failed to execute')
            expect(option[:color]).to eq('red')
          end

          notifier.notify_failure
        end
      end
    end

    describe '#notify_cancellation' do
      before do
        instance.logs.warn('warn')
        instance.job_definition.notify_cancellation = true
        instance.save!
      end

      it 'sends cancellation mesasge' do
        expect(hipchat_room_object).to receive(:send) do |_, message, option|
          expect(message).to include('WARNING')
          expect(option[:color]).to eq('yellow')
        end

        notifier.notify_cancellation
      end
    end

    describe '#notify_critical' do
      it 'sends critical mesasge' do
        expect(hipchat_room_object).to receive(:send) do |_, message, option|
          expect(message).to include('CRITICAL')
          expect(option[:color]).to eq('red')
        end

        notifier.notify_critical
      end

      context 'with additional_text' do
        let(:additional_text) { '@EisukeOishi' }
        before do
          instance.job_definition.hipchat_additional_text = additional_text
          instance.save!
        end

        it 'sends additional message' do
          expect(hipchat_room_object).to receive(:send) do |_, message, option|
            expect(message).to include('Failed to execute')
            expect(option[:color]).to eq('red')
          end

          notifier.notify_failure
        end
      end
    end

    describe '#notify_finished' do
      it 'sends finished mesasge' do
        expect(hipchat_room_object).to receive(:send) do |_, message, option|
          expect(message).to include('SUCCESS')
          expect(option[:color]).to eq('green')
        end

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
          expect(hipchat_room_object).to receive(:send) do |_, message, option|
            expect(message).to include('SUCCESS')
            expect(option[:color]).to eq('yellow')
          end

          notifier.notify_retrying
        end
      end

      context 'without notify_finished' do
        before do
          instance.job_definition.hipchat_notify_finished = false
          instance.save!
        end

        it 'sends retrying mesasge' do
          expect(hipchat_room_object).not_to receive(:send)
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
          expect(hipchat_room_object).to receive(:send) do |_, message, option|
            expect(message).to include('SUCCESS')
            expect(option[:color]).to eq('yellow')
          end

          notifier.notify_skipping
        end
      end

      context 'without notify_finished' do
        before do
          instance.job_definition.hipchat_notify_finished = false
          instance.save!
        end

        it 'sends skipping mesasge' do
          expect(hipchat_room_object).not_to receive(:send)
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
          expect(hipchat_room_object).to receive(:send) do |_, message, option|
            expect(message).to include('SUCCESS')
            expect(option[:color]).to eq('yellow')
          end

          notifier.notify_launch
        end
      end

      context 'without notify_finished' do
        before do
          instance.job_definition.hipchat_notify_finished = false
          instance.save!
        end

        it 'sends launch mesasge' do
          expect(hipchat_room_object).not_to receive(:send)
          notifier.notify_launch
        end
      end
    end

    describe '#notify_long_elapsed_time' do
      it 'sends warning mesasge' do
        expect(hipchat_room_object).to receive(:send) do |_, message, option|
          expect(message).to include('WARNING')
          expect(option[:color]).to eq('red')
        end

        notifier.notify_long_elapsed_time
      end
    end
  end
end
