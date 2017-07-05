require 'rails_helper'

describe Kuroko2::JobSuspendSchedulesController do
  routes { Kuroko2::Engine.routes }

  before { sign_in }
  let(:schedule) { create(:job_schedule, cron: '0 10 * * *') }
  let(:suspend_schedule) { create(:job_suspend_schedule, job_definition: schedule.job_definition, cron: '0 10 * * 1') }

  describe '#index' do
    it do
      get :index, params: { job_definition_id: suspend_schedule.job_definition.id }

      expect(response).to have_http_status(:ok)
      expect(assigns(:suspend_schedule)).to be_new_record
      expect(assigns(:suspend_schedules)).to eq [suspend_schedule]
    end
  end

  describe '#create' do
    it do
      post :create, params: { job_definition_id: suspend_schedule.job_definition.id, job_suspend_schedule: { cron: '0 10 * * 0' } }
      expect(response).to have_http_status(:created)
    end
  end

  describe '#destroy' do

    it do
      delete :destroy, params: { job_definition_id: suspend_schedule.job_definition.id, id: suspend_schedule.id }
      schedule.job_definition.reload

      expect(response).to have_http_status(:ok)
      expect(schedule.job_definition.job_suspend_schedules.size).to be 0
    end
  end
end
