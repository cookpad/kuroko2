require 'rails_helper'

module Kuroko2::Workflow
  describe Engine do
    describe '#process' do

      let(:shell) { Kuroko2::Command::Shell.new(hostname: 'rspec', worker_id: 1, worker: worker) }
      let(:token) { definition.job_instances.first.tokens.first }
      let(:worker) { create(:worker) }

      context 'with simple sequence' do
        let!(:definition) do
          create(:job_definition_with_instances, script: <<-EOF.strip_heredoc)
          noop: noop0
          noop: noop1
          EOF
        end

        specify do
          subject.process(token)
          expect(token.path).to eq '/0-noop'

          subject.process(token)
          expect(token.path).to eq '/1-noop'

          subject.process(token)

          expect(token).to be_finished
          expect(Kuroko2::Token.all.count).to eq 0
        end
      end

      context 'with simple execution' do
        let!(:definition) do
          create(:job_definition_with_instances, script: <<-EOF.strip_heredoc)
            env: NAME=kuroko
            execute: echo Hello, $NAME!
          EOF
        end

        specify do
          subject.process(token)
          subject.process(token)
          subject.process(token)
          shell.execute
          subject.process(token)

          expect(token).to be_finished
          expect(Kuroko2::Token.all.count).to eq 0
        end
      end

      context 'with fork' do
        let!(:definition) do
          create(:job_definition_with_instances, script: <<-EOF.strip_heredoc)
            fork:
              noop: noop1
              noop: noop2
              sequence:
                noop: noop3
                noop: noop4
            noop: noop5
          EOF
        end

        specify do
          subject.process(token)
          expect(token.path).to eq '/0-fork'

          subject.process(token)
          expect(token.children.size).to eq 3

          noop1, noop2, sequence = token.children

          subject.process_all
          [token, noop1, noop2, sequence].each(&:reload)
          expect(token.path).to eq '/0-fork'
          expect(noop1.path).to eq '/0-noop'
          expect(noop2.path).to eq '/0-noop'
          expect(sequence.path).to eq '/0-sequence'

          subject.process_all
          [token, noop1, noop2, sequence].each(&:reload)
          expect(token.path).to eq '/0-fork'
          expect(noop1.path).to eq '/0-noop'
          expect(noop2.path).to eq '/0-noop'
          expect(sequence.path).to eq '/0-sequence/0-noop'
          expect(noop1.status_name).to eq 'finished'
          expect(noop2.status_name).to eq 'finished'
          expect(sequence.status_name).to eq 'working'

          subject.process_all
          [token, noop1, noop2, sequence].each(&:reload)
          expect(token.path).to eq '/0-fork'
          expect(noop1.path).to eq '/0-noop'
          expect(noop2.path).to eq '/0-noop'
          expect(sequence.path).to eq '/0-sequence/1-noop'
          expect(noop1.status_name).to eq 'finished'
          expect(noop2.status_name).to eq 'finished'
          expect(sequence.status_name).to eq 'working'

          subject.process_all
          [token, noop1, noop2, sequence].each(&:reload)
          expect(token.path).to eq '/0-fork'
          expect(noop1.path).to eq '/0-noop'
          expect(noop2.path).to eq '/0-noop'
          expect(sequence.path).to eq '/0-sequence/1-noop'
          expect(noop1.status_name).to eq 'finished'
          expect(noop2.status_name).to eq 'finished'
          expect(sequence.status_name).to eq 'finished'

          subject.process_all
          token.reload
          expect(token.path).to eq '/1-noop'
          expect(token.status_name).to eq 'working'

          subject.process_all
          expect(Kuroko2::Token.all.count).to eq 0
        end
      end

      context 'retry' do
        let!(:definition) do
          create(:job_definition_with_instances, script: <<-EOF.strip_heredoc)
            execute: test -e #{tmpfile}
            noop:
          EOF
        end

        let!(:tmpfile) do
          "/tmp/tmp_workflow_spec_skip.#{Process.pid}"
        end

        after do
          FileUtils.safe_unlink(tmpfile)
        end

        specify do
          subject.process(token)
          subject.process(token)
          shell.execute
          subject.process(token)
          expect(token.status_name).to eq 'failure'

          FileUtils.touch(tmpfile)

          subject.retry(token)

          subject.process(token)
          shell.execute
          subject.process(token)
          subject.process(token)

          expect(token.status_name).to eq 'finished'
          expect(Kuroko2::Token.all.count).to eq 0
        end
      end

      context 'skip' do
        let!(:definition) do
          create(:job_definition_with_instances, script: <<-EOF.strip_heredoc)
            execute: false
            noop:
          EOF
        end

        specify do
          subject.process(token)
          subject.process(token)
          shell.execute
          subject.process(token)

          expect(token.status_name).to eq 'failure'

          subject.skip(token)
          subject.process(token)

          expect(token.status_name).to eq 'finished'
          expect(Kuroko2::Token.all.count).to eq 0
        end
      end

      context 'with auto_skip_error' do
        let!(:definition) do
          create(:job_definition_with_instances, script: <<-EOF.strip_heredoc)
            auto_skip_error: true
            execute: false
            noop:
          EOF
        end

        specify do
          subject.process(token)
          subject.process(token)
          shell.execute
          subject.process(token)
          subject.process(token)
          shell.execute
          subject.process(token)
          subject.process(token)

          expect(token.status_name).to eq 'finished'
          expect(Kuroko2::Token.all.count).to eq 0
        end
      end

      context 'with wait' do
        let(:wait_definition) do
          create(:job_definition_with_instances, script: 'noop:')
        end

        let!(:definition) do
          create(:job_definition_with_instances, script: <<-EOF.strip_heredoc)
            wait: #{wait_definition.id}/hourly
            noop:
          EOF
        end

        specify do
          subject.process(token)
          expect(token.status_name).to eq 'working'
          subject.process(token)
          expect(token.status_name).to eq 'waiting'
          subject.process(token)
          expect(token.status_name).to eq 'waiting'
          subject.process(token)
          expect(token.status_name).to eq 'waiting'
          subject.process(token)
          expect(token.status_name).to eq 'waiting'

          wait_definition.job_instances.first.touch(:finished_at)

          subject.process(token)
          expect(token.status_name).to eq 'working'
          subject.process(token)
          expect(token.status_name).to eq 'finished'
        end
      end
    end
  end
end
