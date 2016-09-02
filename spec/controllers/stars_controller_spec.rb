require 'rails_helper'

describe Kuroko2::StarsController do
  routes { Kuroko2::Engine.routes }

  before { sign_in }

  describe '#create' do
    subject! { xhr :post, :create, { job_definition_id: definition.id } }
    let(:definition) { create :job_definition }

    it do
      expect(response).to have_http_status(:created)
    end
  end

  describe '#destroy' do
    subject! { xhr :delete, :destroy, { job_definition_id: definition.id, id: star.id } }
    let(:star) { create :star, user: controller.current_user, job_definition: definition }
    let(:definition) { create :job_definition }

    it do
      expect(response).to have_http_status(:ok)
      expect(Kuroko2::Star.exists?(star.id)).to be_falsey
    end
  end

end
