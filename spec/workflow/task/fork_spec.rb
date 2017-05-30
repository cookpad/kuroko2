require 'rails_helper'

module Kuroko2::Workflow::Task
  describe Fork do
    let(:parser) { Kuroko2::Workflow::ScriptParser.new(token.script) }
    let(:node) { parser.parse.find(token.path) }
    let(:definition) { create(:job_definition) }
    let(:instance) { create(:job_instance, job_definition: definition) }

    describe '#execute' do
      let(:token) do
        Kuroko2::Token.create(uuid: SecureRandom.uuid, path: '/0-fork', job_definition: definition, job_instance: instance, script: <<-EOF.strip_heredoc)
          fork:
            noop: noop1
            noop: noop2
        EOF
      end

      subject(:task) { Fork.new(node, token) }
      let(:children) { token.children }

      it do
        expect(task.execute).to eq :pass

        expect(children.size).to eq 2
        expect(children.first.script).to eq "noop: noop1\n"
        expect(children.second.script).to eq "noop: noop2\n"
      end
    end

    context 'There are multiple fork tasks' do
      let(:token) do
        Kuroko2::Token.create(uuid: SecureRandom.uuid, job_definition: definition, job_instance: instance, script: <<-EOF.strip_heredoc)
          noop: noop1
          fork:
            noop: noop2
            noop: noop3
          fork:
            noop: noop5
            noop: noop6
        EOF
      end

      it 'processes each fork tasks' do
        expect(node.children.first.path).to eq('/0-noop')
        expect(node.children.second.path).to eq('/1-fork')
        expect(node.children.second.children.first.path).to eq('/1-fork/0-noop')
        expect(node.children.second.children.second.path).to eq('/1-fork/1-noop')
        expect(node.children.third.path).to eq('/2-fork')
        expect(node.children.third.children.first.path).to eq('/2-fork/0-noop')
        expect(node.children.third.children.second.path).to eq('/2-fork/1-noop')

        Kuroko2::Workflow::Engine.new.process_all
        expect(token.reload.path).to eq('/0-noop')

        Kuroko2::Workflow::Engine.new.process_all # create children1
        expect(token.reload.path).to eq('/1-fork')
        Kuroko2::Workflow::Engine.new.process_all # process children1-1
        expect(token.reload.path).to eq('/1-fork')
        Kuroko2::Workflow::Engine.new.process_all # process children1-2
        expect(token.reload.path).to eq('/1-fork')
        Kuroko2::Workflow::Engine.new.process_all # check all children1 finished
        expect(token.reload.path).to eq('/1-fork')

        Kuroko2::Workflow::Engine.new.process_all # create children2
        expect(token.reload.path).to eq('/2-fork')
        Kuroko2::Workflow::Engine.new.process_all # process children2-1
        expect(token.reload.path).to eq('/2-fork')
        Kuroko2::Workflow::Engine.new.process_all # process children2-2
        expect(token.reload.path).to eq('/2-fork')
        Kuroko2::Workflow::Engine.new.process_all # check all children2 finished
        expect(token.reload.path).to eq('/2-fork')

        Kuroko2::Workflow::Engine.new.process_all
        expect(Kuroko2::Token.where(id: token.id)).not_to exist
      end
    end
  end
end
