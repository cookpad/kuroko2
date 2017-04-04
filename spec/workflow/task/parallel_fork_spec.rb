require 'rails_helper'

module Kuroko2::Workflow::Task
  describe ParallelFork do
    let(:node) { Kuroko2::Workflow::ScriptParser.new(token.script).parse.find(token.path) }
    let(:definition) { create(:job_definition) }
    let(:instance) { create(:job_instance, job_definition: definition) }

    let(:token) do
      Kuroko2::Token.create(uuid: SecureRandom.uuid, path: '/0-fork', job_definition: definition, job_instance: instance, script: <<-EOF)
parallel_fork: 2
  noop:
      EOF
    end

    describe '#execute' do
      subject(:task) { ParallelFork.new(node, token) }
      let(:children) { token.children }

      it do
        expect(task.execute).to eq :pass
        expect(children.size).to eq 2
      end
    end
  end
end
