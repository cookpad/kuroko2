require 'rails_helper'

module Kuroko2::Workflow::Task
  describe ParallelFork do
    let(:node) { Kuroko2::Workflow::ScriptParser.new(token.script).parse.find(token.path) }
    let(:definition) { create(:job_definition) }
    let(:instance) { create(:job_instance, job_definition: definition) }
    let(:script) do
      <<-EOF.strip_heredoc
        parallel_fork: 2
          noop:
      EOF
    end

    let(:token) do
      Kuroko2::Token.create(uuid: SecureRandom.uuid, path: '/0-fork', job_definition: definition, job_instance: instance, script: script)
    end

    let(:task) { ParallelFork.new(node, token) }

    describe '#validate' do
      context 'with valid script format' do
        it 'passes validation' do
          expect{ task.validate }.not_to raise_error
        end
      end

      context 'with invalid option' do
        let(:script) do
          <<-EOF.strip_heredoc
            parallel_fork: B
              noop:
          EOF
        end

        it 'raises AssertionError' do
          expect{ task.validate }.to raise_error(Kuroko2::Workflow::AssertionError)
        end
      end

      context 'with invalid script format' do
        let(:script) do
          <<-EOF.strip_heredoc
            parallel_fork: 100
          EOF
        end

        it 'raises AssertionError' do
          expect{ task.validate }.to raise_error(Kuroko2::Workflow::AssertionError)
        end
      end
    end

    describe '#execute' do
      let(:children) { token.children }

      it do
        expect(task.execute).to eq :pass
        expect(children.size).to eq 2
      end
    end
  end
end
