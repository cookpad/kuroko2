require 'spec_helper'

module Kuroko2::Workflow
  describe ScriptParser do
    subject(:parser) { ScriptParser.new(script) }

    let(:root) { parser.parse }

    describe '#parse' do
      context 'with simple sequence' do
        around do |example|
          Node.register(key: :task1, klass: Task::Base)
          Node.register(key: :task2, klass: Task::Base)
          Node.register(key: :task3, klass: Task::Base)
          Node.register(key: :task4, klass: Task::Base)

          example.run

          Node.deregister(:task1)
          Node.deregister(:task2)
          Node.deregister(:task3)
          Node.deregister(:task4)
        end

        let(:script) do
          <<-EOF
# comment
task1: # comment
  task2: option

task3: option # comment
task4: OPTION='#option' # comment
          EOF
        end

        it 'returns parsed nodes' do
          expect(root.children.size).to eq 3

          task1 = root.children.first
          expect(task1.type).to eq :task1
          expect(task1.children.size).to eq 1

          task2 = task1.children.first
          expect(task2.type).to eq :task2
          expect(task2.option).to eq 'option'

          task3 = root.children.second
          expect(task3.type).to eq :task3
          expect(task3.option).to eq 'option'

          task4 = root.children.third
          expect(task4.type).to eq :task4
          expect(task4.option).to eq "OPTION='#option'"
        end
      end

      context 'with nested indentation' do
        let(:script) do
          <<-EOF
noop:
  noop: option
    noop: option
  noop:
    noop: option
    noop: option
noop:
          EOF
        end

        it do
          expect(root.children.size).to eq 2
          expect(root.children.first.children.size).to eq 2
          expect(root.children.first.children.first.children.size).to eq 1
          expect(root.children.first.children.second.children.size).to eq 2
        end
      end

      context 'with bad syntax' do
        let(:script) { ':' }

        it { expect { root }.to raise_error(Kuroko2::Workflow::SyntaxError) }
      end

      context 'with bad syntax' do
        let(:script) do
          <<-EOF
noop
          EOF
        end

        it { expect { root }.to raise_error(Kuroko2::Workflow::SyntaxError) }
      end

      context 'with inconsistent indentation' do
        let(:script) do
          <<-EOF
noop:
    noop: option
  noop: option
          EOF
        end

        it { expect { root }.to raise_error(Kuroko2::Workflow::SyntaxError) }
      end

      context 'with bad semantics' do
        let(:script) do
          <<-EOF
fork:
  timeout: a
  noop:
          EOF
        end

        it { expect { root }.to raise_error(Kuroko2::Workflow::AssertionError) }
      end
    end
  end
end
