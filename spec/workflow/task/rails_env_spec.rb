require 'rails_helper'

module Kuroko2::Workflow::Task
  describe RailsEnv do
    describe '#execute' do
      let(:rails_env) { 'test' }
      let(:node) { Kuroko2::Workflow::Node.new(:rails_env, rails_env) }
      let(:token) { build(:token, context: {}) }

      subject { RailsEnv.new(node, token).execute }

      context 'with valid rails_env' do
        it "sets RAILS_ENV" do
          subject
          expect(token.context).to eq({ 'RAILS_ENV' => 'test' })
        end
      end

      context 'with invalid rails_env' do
        let(:rails_env){ 'production' }
        it { expect{ subject }.to raise_error(Kuroko2::Workflow::AssertionError) }
      end

      context 'with not exists rails_env' do
        let(:rails_env){ 'xxxxxxx' }
        it { expect{ subject }.to raise_error(Kuroko2::Workflow::AssertionError) }
      end
    end
  end
end
