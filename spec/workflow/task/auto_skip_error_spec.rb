require 'rails_helper'

module Kuroko2::Workflow::Task
  describe AutoSkipError do
    describe '#execute' do
      let(:node) { Kuroko2::Workflow::Node.new('auto_skip_error', 'true') }
      let(:token) { build(:token, context: {}) }

      subject { AutoSkipError.new(node, token).execute }

      it "sets AUTO_SKIP_ERROR context" do
        subject
        expect(token.context).to eq({ 'AUTO_SKIP_ERROR' => true })
      end

      context 'Without options' do
        let(:node) { Kuroko2::Workflow::Node.new('auto_skip_error') }

        it "sets AUTO_SKIP_ERROR context to false" do
          subject
          expect(token.context).to eq({ 'AUTO_SKIP_ERROR' => false })
        end
      end

      context 'With false options' do
        let(:node) { Kuroko2::Workflow::Node.new('auto_skip_error', 'false') }

        it "sets AUTO_SKIP_ERROR context to false" do
          subject
          expect(token.context).to eq({ 'AUTO_SKIP_ERROR' => false })
        end
      end
    end
  end
end
