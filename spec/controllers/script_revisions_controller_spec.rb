require 'rails_helper'

describe Kuroko2::ScriptRevisionsController do
  routes { Kuroko2::Engine.routes }

  before { sign_in }

  let!(:definition) { create(:job_definition, script: "noop:\n") }
  before do
    1.upto(3) { |i| definition.update_and_record_revision({script: "noop:\n" * i}) }
  end

  describe '#index' do
    subject! { get :index, params: { job_definition_id: definition.id } }

    it do
      expect(response).to have_http_status(:ok)
      expect(response).to render_template('index')

      expect(assigns(:definition)).to eq definition
      expect(assigns(:revisions).size).to eq 3
    end
  end
end
