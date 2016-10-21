require 'rails_helper'

describe Kuroko2::JobInstance do
  let(:log) { Kuroko2::Log.take }

  describe '#logs' do
    let(:definition) { create(:job_definition) }
    let(:instance) { create(:job_instance, job_definition: definition) }

    it do
      instance.logs.info('log info')
      expect(log.level).to eq 'INFO'
    end
  end

  describe '#initialize' do
    let(:definition) { create(:job_definition) }
    let(:instance) { definition.job_instances.create! }

    it do
      expect(instance.tokens.count).to eq 1
      expect(instance.reload.tokens.count).to eq 1
      expect(instance.tokens.first.script).to eq instance.job_definition.script
    end

    context 'Overwrite script on creating' do
      let(:script) { 'env: ALTERNATIVE=1' }
      let(:instance) { definition.job_instances.create!(script: script) }

      it 'Inject alternative script to the instance' do
        expect(instance.tokens.count).to eq 1
        expect(instance.tokens.first.script).to eq script
      end
    end
  end

  describe '#cancel' do
    let(:definition) { create(:job_definition) }
    let(:instance) { definition.job_instances.create! }

    subject! { instance.cancel }

    it do
      expect(instance).to be_canceled_at
      expect(instance.tokens.size).to eq 0
      expect(instance.executions.size).to eq 0
    end
  end

  describe '#generate_token' do
    before do
      ActionMailer::Base.deliveries.clear
      create(:job_instance, job_definition: definition)
    end
    subject! { definition.job_instances.create }

    context 'notify_cancellation is false' do
      let(:definition) { create(:job_definition, notify_cancellation: false, prevent_multi: true) }

      it { expect(ActionMailer::Base.deliveries).to be_empty }
    end

    context 'notify_cancellation is false' do
      let(:definition) { create(:job_definition, notify_cancellation: true, prevent_multi: true) }

      it { expect(ActionMailer::Base.deliveries).not_to be_empty }
    end
  end

  describe '#status' do
    let(:instance) do
      create(
        :job_instance,
        finished_at:    finished_at,
        error_at:       error_at,
        canceled_at:    canceled_at,
        job_definition: definition,
      )
    end
    let(:finished_at) { nil }
    let(:error_at)    { nil }
    let(:canceled_at) { nil }
    let(:definition) { create(:job_definition) }

    context 'with finished_at present' do
      let(:finished_at) { Time.current }

      it 'returns "success"' do
        expect(instance.status).to eq('success')
      end
    end

    context 'with canceled_at present' do
      let(:canceled_at) { Time.current }

      it 'returns "canceled"' do
        expect(instance.status).to eq('canceled')
      end
    end

    context 'with error_at present' do
      let(:error_at) { Time.current }

      it 'returns "error"' do
        expect(instance.status).to eq('error')
      end
    end

    context 'when no timestamp is set' do
      it 'returns "working"' do
        expect(instance.status).to eq('working')
      end
    end
  end
end
