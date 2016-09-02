require 'rails_helper'

describe Kuroko2::Execution do

  describe '.poll' do
    context 'with active execution' do
      let(:definition) { create(:job_definition) }
      let(:token) { create(:token) }

      context 'default queue' do
        subject { Kuroko2::Execution.poll }
        let!(:execution) { create(:execution, job_definition: definition, token: token, started_at: nil) }

        it { is_expected.to eq execution }
      end

      context 'given queue' do
        subject { Kuroko2::Execution.poll(queue) }
        let!(:execution) { create(:execution, job_definition: definition, token: token, started_at: nil, queue: queue) }
        let(:queue) { 'QUEUE' }

        it { is_expected.to eq execution }
      end
    end
  end
end
