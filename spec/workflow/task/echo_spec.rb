require 'rails_helper'

module Kuroko2::Workflow::Task
  describe Echo do
    describe '#execute' do
      subject { Node.new().execute }

      context 'with valid syntax' do
        let(:definition) { create(:job_definition, script: "echo:") }
        let(:instance) { create(:job_instance, job_definition: definition) }
        let(:option) { "hello, world" }
        let(:node) { Kuroko2::Workflow::Node.new(:echo, option) }
        let(:token) { build(:token, job_definition: definition, job_instance: instance) }

        it { expect(Echo.new(node, token).execute).to eq(:next) }
      end
    end
  end
end
