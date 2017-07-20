require 'rails_helper'

describe Kuroko2::JobInstancesController do
  routes { Kuroko2::Engine.routes }

  before { sign_in }

  let(:definition) { create(:job_definition_with_instances, job_instances_count: num_instances) }

  describe '#index' do
    let(:num_instances) { 2 }
    before { get :index, params: { job_definition_id: definition.id } }

    it do
      expect(response).to have_http_status(:ok)
      expect(response).to render_template('index')

      expect(assigns(:definition)).to eq definition
      expect(assigns(:instances).size).to eq num_instances
    end
  end

  describe '#create' do
    let(:num_instances) { 2 }
    before { post :create, params: { job_definition_id: definition.id }, xhr: true }

    it do
      expect(response).to have_http_status(:ok)

      expect(assigns(:definition)).to eq definition
    end

    context 'with Ad-Hoc `script` parameter' do
      let(:script) { "execute: echo 1" }
      before { post :create, params: { job_definition_id: definition.id, job_definition: { script: script } }, xhr: true }
      it 'creates instance in Ad-Hoc script' do
        expect(assigns(:instance).script).to eq script
      end
    end

    context 'with Ad-Hoc `empty script` parameter' do
      let(:script) { "" }
      before { post :create, params: { job_definition_id: definition.id, job_definition: { script: script } }, xhr: true }
      it 'creates instance in Ad-Hoc script' do
        expect(assigns(:instance).script).to eq "noop:\n"
      end
    end

    context 'with Ad-Hoc `invalid script` parameter' do
      let(:script) { "error" }
      before { post :create, params: { job_definition_id: definition.id, job_definition: { script: script } }, xhr: true }
      it 'creates instance in Ad-Hoc script' do
        expect(assigns(:instance)).to eq ["There are syntax errors on script: (line 1) syntax error."]
      end
    end
  end

  describe '#destroy' do
    before do
      instance.tokens.each do |token|
        token.update_column(:status, Kuroko2::Token::FAILURE)
      end

      delete :destroy, params: { job_definition_id: definition, id: instance }
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
