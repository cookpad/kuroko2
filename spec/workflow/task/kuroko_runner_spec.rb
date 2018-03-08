require 'rails_helper'

module Kuroko2::Workflow::Task
  describe KurokoRunner do
    describe '#shell' do
      let(:definition) { create(:job_definition, script: "kuroko_runner: #{option}") }
      let(:instance) { create(:job_instance, job_definition: definition) }
      let(:node) { Kuroko2::Workflow::Node.new(:kuroko_runner, option) }
      let(:token) { build(:token, job_definition: definition, job_instance: instance) }

      let(:shell) { KurokoRunner.new(node, token).shell }

      context 'with script in engine' do
        let(:option) { 'cleanup_old_instances' }

        it { expect(shell).to include("kuroko2/bin/#{option}.rb") }
      end

      context 'with script in project' do
        let(:option) { 'script_in_project' }

        it { expect(shell).to include("spec/dummy/bin/#{option}.rb") }
      end
    end
  end
end
