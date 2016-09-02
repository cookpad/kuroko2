require 'rails_helper'

module Kuroko2::Command
  describe Kill do

    describe '#execute' do
      subject { Kill.new('test', '1').execute }

      before { Process.detach(pid) }

      let!(:signal) { create(:process_signal, pid: pid, hostname: 'test') }
      let(:pid) { Process.spawn('sleep 10') }

      it 'terminates spawned process' do
        is_expected.to eq signal
        expect { Process.kill(0, pid) }.to raise_error(Errno::ESRCH)
      end
    end
  end
end
