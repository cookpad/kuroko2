require 'rails_helper'

module Workflow::Task
  describe Fork do
    let(:node) { Workflow::ScriptParser.new(token.script).parse.find(token.path) }
    let(:definition) { create(:job_definition) }
    let(:instance) { create(:job_instance, job_definition: definition) }

    let(:token) do
      Token.create(uuid: SecureRandom.uuid, path: '/0-fork', job_definition: definition, job_instance: instance, script: <<-EOF)
fork:
  noop: noop1
  noop: noop2
      EOF
    end

    describe '#execute' do
      subject(:task) { Fork.new(node, token) }
      let(:children) { token.children }

      it do
        expect(task.execute).to eq :pass

        expect(children.size).to eq 2
        expect(children.first.script).to eq "noop: noop1\n"
        expect(children.second.script).to eq "noop: noop2\n"
      end
    end
  end
end
