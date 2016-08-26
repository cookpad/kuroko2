require 'rails_helper'

module Workflow::Task
  describe Env do
    describe '#execute' do
      let(:token) { build(:token, script: 'env:', context: { 'ENV' => { 'EXISTING' => 'true' } }) }

      context 'with valid syntax' do
        before { Env.new(node, token).execute }
        subject { token.context }

        context 'with nil option' do
          let(:node) { Workflow::Node.new(:env) }

          context 'with exisiting env' do
            it { is_expected.to eq({ 'ENV' => { 'EXISTING' => 'true' } }) }
          end

          context 'without exisiting env' do
            let(:token) { build(:token, script: 'env:') }

            it { is_expected.to eq({}) }
          end
        end

        context 'with valid option' do
          let(:node) { Workflow::Node.new(:env, 'A=1 B=2') }

          it { is_expected.to eq({ 'ENV' => { 'A' => '1', 'B' => '2', 'EXISTING' => 'true' } }) }
        end

        context 'with quote' do
          let(:node) { Workflow::Node.new(:env, 'A="B=2 C=3"  D="E=5 F=\"6"' " G='\\'7'") }

          it { is_expected.to eq({ 'ENV' => { 'A' => 'B=2 C=3', 'D' => 'E=5 F="6', 'G' => "'7", 'EXISTING' => 'true' } }) }
        end
      end

      context 'with invalid syntax' do
        let(:node) { Workflow::Node.new(:env, 'A="B=2 C=3" D="E=5 F=\"6') }

        it { expect { Env.new(node, token).execute }.to raise_error(Workflow::AssertionError) }
      end
    end

  end
end
