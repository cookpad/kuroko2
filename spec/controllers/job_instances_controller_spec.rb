require 'rails_helper'

describe Kuroko2::JobInstancesController do
  before { sign_in }

  let(:definition) { create(:job_definition_with_instances, job_instances_count: num_instances) }

  describe '#index' do
    let(:num_instances) { 2 }
    before { get :index, job_definition_id: definition.id }

    it do
      expect(response).to have_http_status(:ok)
      expect(response).to render_template('index')

      expect(assigns(:definition)).to eq definition
      expect(assigns(:instances).size).to eq num_instances
    end
  end

  describe '#create' do
    let(:num_instances) { 2 }
    before { xhr :post, :create, job_definition_id: definition.id }

    it do
      expect(response).to redirect_to(job_definition_job_instance_path(definition, assigns(:instance)))

      expect(assigns(:definition)).to eq definition
    end

    context 'with Ad-Hoc `script` parameter' do
      let(:script) { "execute: echo 1" }
      before { xhr :post, :create, job_definition_id: definition.id, job_definition: { script: script } }
      it 'creates instance in Ad-Hoc script' do
        expect(assigns(:instance).script).to eq script
      end
    end
  end

  describe '#destroy' do
    before do
      instance.tokens.each do |token|
        token.update_column(:status, Token::FAILURE)
      end

      delete :destroy, job_definition_id: definition, id: instance
    end

    let(:num_instances) { 1 }
    let(:instance) { definition.job_instances.first }

    it do
      instance.reload

      expect(response).to redirect_to(job_definition_job_instance_path(definition, instance))
      expect(instance.tokens.size).to eq 0
    end

  end
end
