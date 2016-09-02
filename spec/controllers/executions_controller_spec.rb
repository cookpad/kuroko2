require 'rails_helper'

describe Kuroko2::ExecutionsController do
  routes { Kuroko2::Engine.routes }

  before { sign_in }

  describe '#destroy' do
    let(:definition) { create(:job_definition) }
    let(:instance) { create(:job_instance, job_definition: definition) }
    let(:token) { create(:token, job_instance: instance) }
    let(:execution) { create(:execution, token: token, exit_status: nil, pid: 1) }
    let!(:worker) { create(:worker, execution: execution) }

    subject! { delete :destroy, job_definition_id: definition.id, job_instance_id: instance.id, id: execution.id }

    it do
      expect(response).to redirect_to(job_definition_job_instance_path(job_definition_id: definition.id, id: instance.id))
      expect(Kuroko2::ProcessSignal.count).to eq 1
    end
  end

end
