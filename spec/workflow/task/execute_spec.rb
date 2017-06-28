require 'rails_helper'

module Kuroko2::Workflow::Task
  describe Execute do
    subject { Execute.new(node, token).execute }

    let(:context) { { 'ENV' => { 'NAME' => 'alice' } } }
    let(:node) { Kuroko2::Workflow::Node.new(:execute, shell) }

    let(:token) { create(:token, path: '/', script: 'execute:', context: context, job_definition: definition, job_instance: instance) }
    let(:execution) { Kuroko2::Execution.take }
    let(:definition) { create(:job_definition, script: "execute: echo HELLO\n") }
    let(:instance) do
      create(:job_instance, job_definition: definition).tap do |instance|
        instance.tokens.destroy
      end
    end

    context 'with shell script' do
      let(:shell) { 'echo $NAME' }

      specify do
        is_expected.to eq :pass

        expect(Kuroko2::Execution.all.size).to eq 1
        expect(execution.token).to eql token
        expect(execution.shell).to eq shell
        expect(execution.context['ENV']).to eq context['ENV']
      end
    end

    context 'with successfully completed' do
      before do
        create(:execution, token: token)
      end

      let(:shell) { 'echo $NAME' }

      specify do
        is_expected.to eq :next

        expect(Kuroko2::Execution.all.size).to eq 0
        expect(Kuroko2::Log.all.count).to eq 1
      end
    end

    context 'With TIMEOUT' do
      let(:shell) { 'sleep 5 && echo $NAME' }
      let(:pid) { 1 }
      let(:hostname) { 'myhost' }

      around do |example|
        Execute.new(node, token).execute

        execution = Kuroko2::Execution.of(token).take
        execution.update!(pid: pid)
        create(:worker, hostname: hostname, execution_id: execution.id)

        token.context['TIMEOUT'] = '1' # 1 minute
        Timecop.travel(2.minutes.since) { example.run }
      end

      it 'creates one ProcessSignal' do
        expect { Execute.new(node, token).execute }.to change { Kuroko2::ProcessSignal.where(pid: execution.pid, hostname: hostname).count }.from(0).to(1)
        expect { Execute.new(node, token).execute }.to_not change { Kuroko2::ProcessSignal.where(pid: execution.pid, hostname: hostname).count }.from(1)
      end
    end
  end
end
