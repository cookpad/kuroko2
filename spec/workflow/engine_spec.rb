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

      context 'with parallel_fork' do
        let!(:definition) do
          create(:job_definition_with_instances, script: <<-EOF.strip_heredoc)
            env: GLOBAL_ENV=g
            parallel_fork: 3
              noop: noop1
              noop: noop2
            noop: noop3
          EOF
        end

        specify do
          subject.process(token)
          expect(token.path).to eq '/0-env'
          subject.process(token)
          expect(token.path).to eq '/1-parallel_fork'

          subject.process(token)
          expect(token.children.size).to eq 3

          parallel_tokens = token.children
          subject.process_all

          parallel_tokens.each(&:reload)
          expect(token.path).to eq '/1-parallel_fork'
          expect(parallel_tokens.map(&:path)).to all(eq('/0-sequence'))

          subject.process_all
          parallel_tokens.each(&:reload)
          expect(token.path).to eq '/1-parallel_fork'
          expect(parallel_tokens.map(&:path)).to all(eq('/0-sequence/0-noop'))
          expect(parallel_tokens.map(&:status_name)).to all(eq('working'))
          expect(parallel_tokens.map{ |token| token.context['ENV']['KUROKO2_PARALLEL_FORK_SIZE'] }).to all(eq('3'))
          expect(parallel_tokens.map{ |token| token.context['ENV']['GLOBAL_ENV'] }).to all(eq('g'))
          expect(parallel_tokens[0].context['ENV']['KUROKO2_PARALLEL_FORK_INDEX']).to eq('0')
          expect(parallel_tokens[1].context['ENV']['KUROKO2_PARALLEL_FORK_INDEX']).to eq('1')
          expect(parallel_tokens[2].context['ENV']['KUROKO2_PARALLEL_FORK_INDEX']).to eq('2')

          subject.process_all
          parallel_tokens.each(&:reload)
          expect(token.path).to eq '/1-parallel_fork'
          expect(parallel_tokens.map(&:path)).to all(eq('/0-sequence/1-noop'))
          expect(parallel_tokens.map(&:status_name)).to all(eq('working'))
          expect(parallel_tokens.map{ |token| token.context['ENV']['KUROKO2_PARALLEL_FORK_SIZE'] }).to all(eq('3'))
          expect(parallel_tokens.map{ |token| token.context['ENV']['GLOBAL_ENV'] }).to all(eq('g'))
          expect(parallel_tokens[0].context['ENV']['KUROKO2_PARALLEL_FORK_INDEX']).to eq('0')
          expect(parallel_tokens[1].context['ENV']['KUROKO2_PARALLEL_FORK_INDEX']).to eq('1')
          expect(parallel_tokens[2].context['ENV']['KUROKO2_PARALLEL_FORK_INDEX']).to eq('2')

          subject.process_all
          parallel_tokens.each(&:reload)
          expect(token.path).to eq '/1-parallel_fork'
          expect(parallel_tokens.map(&:path)).to all(eq('/0-sequence/1-noop'))
          expect(parallel_tokens.map(&:status_name)).to all(eq('finished'))

          subject.process(token)
          expect(token.path).to eq '/2-noop'
          expect(token.status_name).to eq 'working'
          expect(token.context['ENV']['GLOBAL_ENV']).to eq('g')
          expect(token.context['ENV']['KUROKO2_PARALLEL_FORK_SIZE']).to be_nil
          expect(token.context['ENV']['KUROKO2_PARALLEL_FORK_INDEX']).to be_nil

          subject.process_all
          expect(Kuroko2::Token.all.count).to eq 0
        end
      end

      context 'if passed EXPECTED_TIME' do
        context 'without EXPECTED_TIME' do
          let!(:definition) do
            create(:job_definition_with_instances, script: <<-EOF.strip_heredoc)
              noop:
            EOF
          end

          it 'notifies messages' do
            expect(Kuroko2::Workflow::Notifier).to receive(:notify).with(:long_elapsed_time, token.job_instance)
            Timecop.travel((24.hours + 1.second).since) {
              subject.process(token)
              expect(token.context['EXPECTED_TIME_NOTIFIED_AT']).to be_present
            }
          end
        end

        context 'with EXPECTED_TIME' do
          let!(:definition) do
            create(:job_definition_with_instances, script: <<-EOF.strip_heredoc)
              expected_time: 1m
              noop: noop1
              noop: noop2
              noop: noop3
              noop: noop4
            EOF
          end

          it 'notifies messages and wait notifing until EXPECTED_TIME_NOTIFY_REMIND_TERM' do
            subject.process(token)
            subject.process(token)

            expect(Kuroko2::Workflow::Notifier).to receive(:notify).with(:long_elapsed_time, token.job_instance).twice

            Timecop.travel((1.minutes + 1.second).since) {
              subject.process(token) # notify
              expect(token.context['EXPECTED_TIME_NOTIFIED_AT']).to be_present
              subject.process(token) # do not notify until EXPECTED_TIME_NOTIFIED_AT + EXPECTED_TIME_NOTIFY_REMIND_TERM

              Timecop.travel((1.hours + 1.second).since) {
                subject.process(token) # notify
              }
            }
          end
        end

        context 'with fork process' do
          let(:engine) { Kuroko2::Workflow::Engine.new }

          context 'if expected_time sets root only' do
            let!(:definition) do
              create(:job_definition_with_instances, script: <<-EOF.strip_heredoc)
                fork:
                  noop: noop_fork1
                  noop: noop_fork2
              EOF
            end

            it 'notifies once from the parent token only' do
              expect(Kuroko2::Workflow::Notifier).to receive(:notify).with(:long_elapsed_time, token.job_instance).once
              engine.process_all
              engine.process_all

              Timecop.travel((24.hours + 1.second).since) {
                engine.process_all
                expect(token.reload.context['EXPECTED_TIME_NOTIFIED_AT']).to be_present
                engine.process_all
              }
            end
          end

          context 'if expected_time settings is different between root and children' do
            let!(:definition) do
              create(:job_definition_with_instances, script: <<-EOF.strip_heredoc)
                expected_time: 1h
                parallel_fork: 2
                  expected_time: 1m
                  noop: noop_parallel_fork1
                  noop: noop_parallel_fork2
              EOF
            end

            it 'notifies from each tokens' do
              expect(Kuroko2::Workflow::Notifier).to receive(:notify).with(:long_elapsed_time, token.job_instance).twice
              engine.process_all
              engine.process_all
              engine.process_all

              Timecop.travel((1.minute + 1.second).since) {
                engine.process_all
                engine.process_all
                engine.process_all
                token.reload
                expect(token.context['EXPECTED_TIME_NOTIFIED_AT']).not_to be_present
                expect(token.children.map{|child| child.context['EXPECTED_TIME_NOTIFIED_AT']}).to all(be_present)

                engine.process_all
              }
            end
          end
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

          expect(token.job_instance.retrying?).to be_falsy
          subject.retry(token)
          expect(token.job_instance.retrying?).to be_truthy

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

      context 'with retry' do
        let!(:definition) do
          create(:job_definition_with_instances, script: <<-EOF.strip_heredoc)
            retry: count=3 sleep_time=0
              noop:
              noop:
          EOF
        end

        let(:root) { ScriptParser.new(token.script).parse(validate: false) }
        let(:object) { Task::Noop.new(root.next.next, token) }
      
        before do
          allow(Task::Noop).to receive(:new).and_return(object)
        end

        it 'passes all tasks' do
          subject.process(token)
          subject.process(token)
          expect(token.context['RETRY']['/0-retry/0-noop']['retried_count']).to eq 0
          expect(token.status_name).to eq 'working'
          allow(object).to receive(:execute).and_return(:failure)
          subject.process(token)
          expect(token.context['RETRY']['/0-retry/0-noop']['retried_count']).to eq 1
          expect(token.status_name).to eq 'working'
          subject.process(token)
          expect(token.context['RETRY']['/0-retry/0-noop']['retried_count']).to eq 2
          expect(token.status_name).to eq 'working'
          allow(object).to receive(:execute).and_return(:next)
          subject.process(token)
          expect(token.context['RETRY']['/0-retry/0-noop']['retried_count']).to eq 2
          expect(token.status_name).to eq 'working'
          subject.process(token)
          expect(token.status_name).to eq 'finished'
        end

        it 'fails in /0-retry/0-noop' do
          subject.process(token)
          subject.process(token)
          expect(token.context['RETRY']['/0-retry/0-noop']['retried_count']).to eq 0
          expect(token.status_name).to eq 'working'
          allow(object).to receive(:execute).and_return(:failure)
          subject.process(token)
          expect(token.context['RETRY']['/0-retry/0-noop']['retried_count']).to eq 1
          expect(token.status_name).to eq 'working'
          subject.process(token)
          expect(token.context['RETRY']['/0-retry/0-noop']['retried_count']).to eq 2
          expect(token.status_name).to eq 'working'
          subject.process(token)
          expect(token.context['RETRY']['/0-retry/0-noop']['retried_count']).to eq 3
          expect(token.status_name).to eq 'working'
          subject.process(token)
          expect(token.path).to eq '/0-retry/0-noop'
          expect(token.status_name).to eq 'failure'
        end
      end
    end
  end
end
