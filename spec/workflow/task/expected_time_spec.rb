require 'rails_helper'

module Kuroko2::Workflow::Task
  describe ExpectedTime do
    describe '#execute' do
      let(:node) { Kuroko2::Workflow::Node.new('expected_time', '100') }
      let(:token) { build(:token, context: {}) }

      subject { ExpectedTime.new(node, token).execute }

      it "sets EXPECTED_TIME context" do
        subject
        expect(token.context).to eq({ 'EXPECTED_TIME' => 100 })
      end

      context 'With %d+h type' do
        let(:node) { Kuroko2::Workflow::Node.new('expected_time', '10h') }

        it "sets EXPECTED_TIME context" do
          subject
          expect(token.context).to eq({ 'EXPECTED_TIME' => 10*60 })
        end
      end

      context 'With %d+m type' do
        let(:node) { Kuroko2::Workflow::Node.new('expected_time', '10m') }

        it "sets EXPECTED_TIME context" do
          subject
          expect(token.context).to eq({ 'EXPECTED_TIME' => 10 })
        end
      end

      context 'Without options' do
        let(:node) { Kuroko2::Workflow::Node.new('expected_time') }

        it "does not sets EXPECTED_TIME context" do
          subject
          expect(token.context).to eq({})
        end
      end

      context 'With non integer value' do
        let(:node) { Kuroko2::Workflow::Node.new('expected_time', 'abc') }

        it "raises error" do
          expect { subject }.to raise_error(Kuroko2::Workflow::AssertionError)
        end
      end
    end
  end
end
