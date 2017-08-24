require 'rails_helper'

module Kuroko2::Workflow::Task
  describe Retry do

    subject(:task) { Retry.new(node, token) }
    let(:node) { Kuroko2::Workflow::ScriptParser.new(token.script).parse.find(token.path).next }
    let(:definition) { create(:job_definition) }
    let(:instance) { create(:job_instance, job_definition: definition) }
    let(:token) do
      Kuroko2::Token.create(uuid: SecureRandom.uuid, job_definition: definition, job_instance: instance, script: script)
    end

    describe '#validate' do
      context 'with valid script format' do
        let(:script) do
          <<-EOF.strip_heredoc
            retry: count=3 sleep_time=10
              noop:
              noop:
            noop:
          EOF
        end

        it 'passes validation' do
          expect{ task.validate }.not_to raise_error
        end
      end

      context 'with invalid option' do
        let(:script) do
          <<-EOF.strip_heredoc
            retry: sleep_time=10
              noop:
          EOF
        end

        it 'raises AssertionError' do
          expect{ task.validate }.to raise_error(Kuroko2::Workflow::AssertionError)
        end
      end
    end

    describe '#execute' do
      context 'with valid script format' do
        let(:script) do
          <<-EOF.strip_heredoc
            retry: count=3 sleep_time=10
              noop:
              noop:
            noop:
          EOF
        end

        it 'passes validation' do
          expect(task.execute).to eq :next
          token.context['RETRY'].each {|path, retry_option|
            expect(retry_option[:retried_count]).to eq 0
            expect(retry_option[:count]).to eq 3
            expect(retry_option[:sleep_time]).to eq 10
          }
        end
      end
    end
  end
end