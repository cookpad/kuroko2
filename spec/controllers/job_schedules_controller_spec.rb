require 'rails_helper'

describe Kuroko2::JobSchedulesController do
  routes { Kuroko2::Engine.routes }

  before { sign_in }

  let(:schedules) { create_list(:job_schedule, 1) }
  let(:definition) { create(:job_definition, job_schedules: schedules) }

  describe '#index' do
    it do
      get :index, params: { job_definition_id: definition.id }

      expect(response).to have_http_status(:ok)
      expect(assigns(:schedule)).to be_new_record
      expect(assigns(:schedules)).to eq schedules
    end
  end

  describe '#create' do
    it do
      post :create, params: { job_definition_id: definition.id, job_schedule: { cron: '* * * * *' } }

      expect(response).to have_http_status(:created)
    end
  end

  describe '#destroy' do

    it do
      delete :destroy, params: { job_definition_id: definition.id, id: schedules.first.id }
      definition.reload

      expect(response).to have_http_status(:ok)
      expect(definition.job_schedules.size).to be 0
    end
  end
end
