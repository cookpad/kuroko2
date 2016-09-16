require 'rails_helper'

describe Kuroko2::JobDefinitionStatsController do
  routes { Kuroko2::Engine.routes }

  before { sign_in }

  let(:instance_num) { 2 }
  let(:definition) do
    create(
      :job_definition_with_instances,
      job_instances_count: instance_num,
      job_instances_token_status: Kuroko2::Token::FINISHED
    )
  end

  before do
    definition.job_instances.first.update!(created_at: 2.months.ago)

    definition.job_instances.each do |instance|
      Kuroko2::MemoryConsumptionLog.create!(job_instance_id: instance.id, value: 1000 + rand(10))
    end
  end

  describe '#index' do
    before { get :index, params: { job_definition_id: definition.id } }

    it do
      expect(response).to have_http_status(:ok)
      expect(response).to render_template('index')
      expect(assigns(:definition)).to eq definition
    end
  end

  describe '#memory' do
    context 'without parameters' do
      before { get :memory, params: { job_definition_id: definition.id }, xhr: true }

      it do
        expect(response).to have_http_status(:ok)
        expect(assigns(:definition)).to eq definition
        expect(assigns(:logs).size).to eq 2
      end
    end

    context 'with period parameter' do
      before { get :memory, params: { job_definition_id: definition.id, period: period }, xhr: true }

      context 'with period is 1d' do
        let(:period) { '1d' }
        it { expect(assigns(:logs).size).to eq 1 }
      end

      context 'with period is 2w' do
        let(:period) { '2w' }
        it { expect(assigns(:logs).size).to eq 1 }
      end

      context 'with period is 3m' do
        let(:period) { '3m' }
        it { expect(assigns(:logs).size).to eq 2 }
      end
    end
  end

  describe '#execution_time' do
    context 'without parameters' do
      before { get :execution_time, params: { job_definition_id: definition.id }, xhr: true }
      it do
        expect(response).to have_http_status(:ok)
        expect(assigns(:definition)).to eq definition
        expect(assigns(:logs).size).to eq 2
      end
    end

    context 'with peripd parameter' do
      before { get :execution_time, params: { job_definition_id: definition.id, period: period }, xhr: true }

      context 'with period is 1d' do
        let(:period) { '1d' }
        it { expect(assigns(:logs).size).to eq 1 }
      end

      context 'with period is 2w' do
        let(:period) { '2w' }
        it { expect(assigns(:logs).size).to eq 1 }
      end

      context 'with period is 3m' do
        let(:period) { '3m' }
        it { expect(assigns(:logs).size).to eq 2 }
      end
    end
  end
end
