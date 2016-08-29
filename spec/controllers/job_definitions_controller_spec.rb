require 'rails_helper'

describe Kuroko2::JobDefinitionsController do
  before { sign_in }

  let(:definition) { create(:job_definition) }

  describe '#index' do
    subject! { get :index }
    let!(:definitions) { create_list(:job_definition, 3) }

    it do
      expect(response).to have_http_status(:ok)
      expect(response).to render_template('index')

      expect(assigns(:definitions)).to eq definitions
    end
  end

  describe '#show' do
    subject! { get :show, id: definition.id }

    it do
      expect(response).to have_http_status(:ok)
      expect(response).to render_template('show')

      expect(assigns(:definition)).to eq definition
    end
  end

  describe '#new' do
    subject! { get :new }
    it do
      expect(response).to have_http_status(:ok)
      expect(response).to render_template('new')

      expect(assigns(:definition)).to be_new_record
    end
  end

  describe '#create' do
    subject! do
      post :create, job_definition: { name: 'Job Definition', description: 'This is description', script: "noop:\n" }
    end

    it do
      expect(response).to redirect_to(assigns(:definition))

      expect(assigns(:definition)).not_to be_new_record
      expect(assigns(:definition).admins).to eq [controller.current_user]
      expect(assigns(:definition).memory_expectancy).not_to be_nil
    end
  end

  describe '#edit' do
    subject! { get :edit, id: definition.id }

    it do
      expect(response).to have_http_status(:ok)
      expect(assigns(:definition)).to eq definition
    end
  end

  describe '#update' do
    let(:admin) { create(:user) }
    subject! do
      patch :update, id: definition.id, job_definition: { name: 'Job Definition', description: 'This is description', script: "noop:\n" }, admin_assignments: { user_id: ["", admin.id] }
    end

    it do
      expect(response).to redirect_to(assigns(:definition))

      expect(assigns(:definition)).not_to be_new_record
    end
  end

  describe '#destroy' do
    subject! { delete :destroy, id: definition.id }

    it do
      expect(response).to redirect_to(job_definitions_path)

      expect(assigns(:definition)).to be_destroyed
    end
  end

end
