require 'rails_helper'

module Kuroko2::Command
  describe Kill do

    describe '#execute' do
      subject { Kill.new(hostname, '1').execute }

      before do
        execution.pid = Process.spawn('sleep 10')
        Process.detach(execution.pid)
        worker.update!(execution_id: execution.id)
      end

      let!(:signal) { create(:process_signal, pid: execution.pid, hostname: 'test', execution_id: execution.id) }
      let(:execution) { create(:execution) }
      let(:hostname) { 'test' }
      let(:worker) { create(:worker, hostname: hostname) }

      it 'terminates spawned process' do
        is_expected.to eq signal
        expect { Process.kill(0, execution.pid) }.to raise_error(Errno::ESRCH)
      end
    end
  end
end
