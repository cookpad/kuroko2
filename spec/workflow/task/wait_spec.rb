require 'rails_helper'

module Workflow::Task
  describe Wait do
    describe '#execute' do
      let(:wait_definition) { create(:job_definition, script: "noop:") }
      let(:wait_instance) { create(:job_instance, job_definition: definition) }

      let(:option) { "#{wait_definition.id}/daily" }
      let(:node) { Workflow::Node.new(:wait, option) }
      let(:now) { Time.zone.now }

      context 'with valid syntax' do
        let(:definition) { create(:job_definition, script: "wait: #{option}") }
        let(:instance) do
          create(:job_instance, job_definition: definition, created_at: Time.now).tap do |instance|
            instance.tokens.destroy
          end
        end

        let(:token) { build(:token, job_definition: definition, job_instance: instance) }

        context 'with single option' do
          it 'returns :wait' do
            expect(Wait.new(node, token).execute).to eq(:pass)
            expect(token.context['WAIT']).to eq({
              "timeout"  => 60.minutes.to_i / 60,
              "jobs" => [{
                "job_definition_id" => wait_definition.id,
                "period" => 'daily',
                "start_from" => now.beginning_of_day.to_s,
                "start_to" => now.end_of_day.to_s,
                "received" => false,
              }]
            })
          end

          context 'if next process' do
            before do
              Wait.new(node, token).execute
            end

            it 'wait jobs' do
              expect(Wait.new(node, token).execute).to eq(:pass)
            end
          end

          context 'if the waiting job is finished' do
            let(:definition) { create(:job_definition, script: "noop:") }
            let(:instance) { create(:job_instance, job_definition: definition) }
            let(:option) { "#{definition.id}/daily" }

            it 'proceeds next task' do
              expect(Wait.new(node, token).execute).to eq(:pass)
              expect(Wait.new(node, token).execute).to eq(:pass)
              instance.touch(:finished_at)
              expect(Wait.new(node, token).execute).to eq(:next)
            end
          end

          context 'if timeout' do
            let(:definition) { create(:job_definition, script: "noop:") }
            let(:instance) { create(:job_instance, job_definition: definition) }
            let(:option) { "#{definition.id}/daily timeout=1m" }

            around do |example|
              Wait.new(node, token).execute
              Timecop.travel((1.minutes + 1.second).since) { example.run }
            end

            it 'fails task' do
              expect(token.context['WAIT']["timeout"]).to eq(1)
              expect(Wait.new(node, token).execute).to eq(:failure)
            end
          end
        end

        context 'with multiple option' do
          let(:option) { "#{wait_definition1.id}/daily #{wait_definition2.id}/daily" }

          let(:wait_definition1) { create(:job_definition, script: "noop:") }
          let(:wait_definition2) { create(:job_definition, script: "noop:") }

          let(:wait_instance1) { create(:job_instance, job_definition: wait_definition1) }
          let(:wait_instance2) { create(:job_instance, job_definition: wait_definition2) }

          it 'returns :wait' do
            expect(Wait.new(node, token).execute).to eq(:pass)
            expect(token.context['WAIT']).to eq({
              "timeout"  => 60.minutes.to_i / 60,
              "jobs" => [
                {
                  "job_definition_id" => wait_definition1.id,
                  "period" => 'daily',
                  "start_from" => now.beginning_of_day.to_s,
                  "start_to" => now.end_of_day.to_s,
                  "received" => false,
                },
                {
                  "job_definition_id" => wait_definition2.id,
                  "period" => 'daily',
                  "start_from" => now.beginning_of_day.to_s,
                  "start_to" => now.end_of_day.to_s,
                  "received" => false,
                },
              ]
            })
          end

          context 'if waiting jobs is finished' do
            it 'proceeds next task' do
              expect(Wait.new(node, token).execute).to eq(:pass)
              expect(Wait.new(node, token).execute).to eq(:pass)
              wait_instance1.touch(:finished_at)
              expect(Wait.new(node, token).execute).to eq(:pass)
              expect(Wait.new(node, token).execute).to eq(:pass)
              expect(Wait.new(node, token).execute).to eq(:pass)
              wait_instance2.touch(:finished_at)
              expect(Wait.new(node, token).execute).to eq(:next)
            end
          end
        end
      end

      context 'with invalid syntax' do
        let(:token) { build(:token, job_instance: build(:job_instance, created_at: Time.now)) }

        context 'with invalid job_definition_id' do
          let(:option) { 'AAA/daily' }
          it 'raise error' do
            expect{ Wait.new(node, token).execute }.
              to raise_error(Workflow::AssertionError)
          end
        end

        context 'with invalid period' do
          let(:option) { "#{wait_definition.id}/minutes" }
          it 'raise error' do
            expect{ Wait.new(node, token).execute }.
              to raise_error(Workflow::AssertionError)
          end
        end

        context 'with undefined job_definition_id' do
          let(:option) { "0/hourly" }
          it 'raise error' do
            expect{ Wait.new(node, token).execute }.
              to raise_error(Workflow::AssertionError)
          end
        end

        context 'with invalid timeout option' do
          let(:option) { "#{wait_definition.id}/hourly timeout=X" }
          it 'raise error' do
            expect{ Wait.new(node, token).execute }.
              to raise_error(Workflow::AssertionError)
          end
        end
      end
    end
  end
end
