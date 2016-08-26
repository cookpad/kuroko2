require 'rails_helper'

module Workflow::Task
  describe Queue do
    describe '#execute' do
      around do |example|
        Timecop.freeze(Time.at(time)) do
          example.run
        end
      end
      before { Sleep.new(node, token).execute }

      let(:token) { build(:token, script: 'sleep:') }
      let(:node) { Workflow::Node.new(:sleep, seconds.to_s) }

      let(:seconds) { 10 }
      let(:time) { 1000000000 }

      it { expect(token.context['SLEEP']).to eq (time + seconds) }
    end
  end
end
