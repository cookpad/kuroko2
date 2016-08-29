require 'rails_helper'

describe Kuroko2::JobDefinitionStatsController do
  before { sign_in }

  let(:instance_num) { 2 }
  let(:definition) do
    create(
      :job_definition_with_instances,
      job_instances_count: instance_num,
      job_instances_token_status: Token::FINISHED
    )
  end

  before do
    definition.job_instances.first.update!(created_at: 2.months.ago)

    definition.job_instances.each do |instance|
      MemoryConsumptionLog.create!(job_instance_id: instance.id, value: 1000 + rand(10))
    end
  end

  describe '#index' do
    before { get :index, job_definition_id: definition.id }

    it do
      expect(response).to have_http_status(:ok)
      expect(response).to render_template('index')
      expect(assigns(:definition)).to eq definition
    end
  end

  describe '#memory' do
    context 'without parameters' do
      before { xhr :get, :memory, job_definition_id: definition.id }

      it do
        expect(response).to have_http_status(:ok)
        expect(assigns(:definition)).to eq definition
        expect(assigns(:logs).size).to eq 2
      end
    end

    context 'with period parameter' do
      before { xhr :get, :memory, job_definition_id: definition.id, period: period }

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
      before { xhr :get, :execution_time, job_definition_id: definition.id }
      it do
        expect(response).to have_http_status(:ok)
        expect(assigns(:definition)).to eq definition
        expect(assigns(:logs).size).to eq 2
      end
    end

    context 'with peripd parameter' do
      before { xhr :get, :execution_time, job_definition_id: definition.id, period: period }

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
