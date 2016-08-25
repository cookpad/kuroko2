require 'rails_helper'

module Workflow::Task
  describe Queue do
    describe '#execute' do
      subject { token.context['QUEUE'] }

      let(:token) { build(:token, script: 'queue:') }
      let(:queue) { Execution::DEFAULT_QUEUE }

      before do
        Worker.create!(hostname: 'test', worker_id: 1, queue: queue, working: true)
      end

      context 'valid case' do
        before { Workflow::Task::Queue.new(node, token).execute }

        context 'with default queue' do
          let(:node) { Workflow::Node.new(:queue) }

          it { is_expected.to eq queue }
        end

        context 'with given queue' do
          let(:queue) { 'queue_name' }
          let(:node) { Workflow::Node.new(:queue, queue) }

          it { is_expected.to eq queue }
        end
      end

      context 'with invalid queue' do
        let(:node) { Workflow::Node.new(:queue, '!invalid!') }

        it { expect { Workflow::Task::Queue.new(node, token).validate }.to raise_error(Workflow::AssertionError) }
      end

      context 'with no existance queue' do
        let(:node) { Workflow::Node.new(:queue, 'invalid') }

        it { expect { Workflow::Task::Queue.new(node, token).validate }.to raise_error(Workflow::AssertionError) }
      end
    end
  end
end
