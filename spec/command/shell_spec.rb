require 'rails_helper'

module Kuroko2::Command
  describe Shell do

    describe '#execute' do
      subject { Shell.new(hostname: 'rspec', worker: worker).execute }

      let(:job_definition) { create(:job_definition) }
      let(:job_instance) { create(:job_instance, job_definition: job_definition) }
      let(:token) { create(:token, job_instance: job_instance, job_definition: job_definition) }
      let!(:execution) { create(:execution, shell: shell, context: { 'ENV' => { 'NAME' => "kuroko" } }, started_at: nil, finished_at: nil, token: token) }
      let(:shell) { 'ruby -e "true"' }

      context 'when available worker exists' do
        let(:worker) { create(:worker) }

        context 'successfully' do
          let(:shell) { 'ruby -e "puts ENV[\'NAME\'] + \\"\\\x99\\""' }

          it do
            is_expected.to eq execution

            expect(subject.started_at).not_to be_nil
            expect(subject.finished_at).not_to be_nil
            expect(subject).to be_success
          end
        end

        context 'failure' do
          let(:shell) { 'wrong_script' }

          it do
            is_expected.to eq execution

            expect(subject.started_at).not_to be_nil
            expect(subject.finished_at).not_to be_nil
            expect(subject).not_to be_success
          end
        end

        context 'with 4byte utf-8 charactor' do
          let(:shell) { 'ruby -e "puts ENV[\'NAME\'] + \\"\xF0\x9F\x98\x81\\""' }

          it do
            is_expected.to eq execution

            expect(subject.started_at).not_to be_nil
            expect(subject.finished_at).not_to be_nil
            expect(subject).to be_success
          end
        end
      end

      context 'when all workers are busy' do
        let(:worker) { create(:worker, execution_id: execution.id) }

        it 'skips execution' do
          is_expected.to be_nil
          execution.reload
          expect(execution.started_at).to be_nil
        end
      end

      describe 'memory expectancy calculation' do
        let(:worker) { create(:worker) }
        let(:memory_expectancy) { execution.job_definition.memory_expectancy }

        context 'when memory consumption logs exist' do
          before do
            (1..10).each {|i| job_instance.create_memory_consumption_log!(value: i) }
          end

          it 'calculates memory expectancy of related job definition' do
            expect { subject }.to change { memory_expectancy.reload.expected_value }
          end
        end

        context 'when no memory consumption logs exist' do
          it 'does not calculates memory expectancy of related job definition' do
            expect { subject }.not_to change { memory_expectancy.reload.expected_value }
          end
        end
      end
    end
  end
end
