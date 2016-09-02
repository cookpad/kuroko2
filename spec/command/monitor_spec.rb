require 'rails_helper'


module Kuroko2::Command
  describe Monitor do
    let(:pid) { 32769 } # max int + 1
    let(:hostname) { 'rspec' }

    let(:definition) { create(:job_definition) }
    let(:instance) { create(:job_instance, job_definition: definition) }
    let(:token) { create(:token, job_definition: definition, job_instance: instance) }
    let(:worker) { create(:worker, hostname: hostname) }

    describe '#execute' do
      let(:sent_mail) { ActionMailer::Base.deliveries.last }

      context 'not running process' do
        let!(:execution) { create(:execution, token: token, worker: worker, started_at: Time.now, finished_at: nil, pid: pid) }
        let(:monitor) { Kuroko2::Command::Monitor.new(hostname: hostname, worker_id: 1) }

        subject! { 15.times { monitor.execute } }

        it 'sends a notification mail' do
          execution.reload

          expect(monitor.counter_size).to be_zero
          expect(sent_mail).not_to be_nil
          expect(sent_mail.subject).to eq '[CRITICAL] Process is not running on kuroko'
          expect(execution.mailed_at).not_to be_nil
        end
      end

      context 'not assigned process' do
        let!(:execution) { create(:execution, token: token, worker: worker, started_at: 2.minutes.ago, finished_at: nil, pid: nil) }
        subject! { Kuroko2::Command::Monitor.new(hostname: hostname, worker_id: 1).execute }

        it 'sends a notification mail' do
          execution.reload

          expect(sent_mail.subject).to eq '[CRITICAL] Process is not assigned to any job-executor'
          expect(execution.mailed_at).not_to be_nil
        end
      end
    end

    describe 'memory consumption monitoring' do
      let!(:execution) { create(:execution, token: token, worker: worker, started_at: Time.now, finished_at: nil, pid: pid) }
      let(:monitor) { Kuroko2::Command::Monitor.new(hostname: hostname, worker_id: 1) }
      before do
        allow(monitor).to receive(:check_process_absence).and_return(true)
        allow(Kuroko2::MemorySampler).to receive(:get_by_pgid).and_return(1)
      end

      it 'logs memory consumption' do
        expect {
          monitor.execute
        }.to change {
          execution.job_definition.memory_expectancy.memory_consumption_logs.count
        }.from(0).to(1)

        log = execution.job_definition.memory_expectancy.memory_consumption_logs.first
        expect(log.value).to be_kind_of(Integer)
        expect(log.value).not_to eq(0)
        expect(log.job_instance_id).to eq(instance.id)
      end
    end
  end
end
