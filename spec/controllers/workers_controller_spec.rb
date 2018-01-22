require 'rails_helper'

RSpec.describe Kuroko2::WorkersController, :type => :controller do
  routes { Kuroko2::Engine.routes }

  before { sign_in }

  let(:worker) { create(:worker) }

  describe '#update' do
    subject! { patch :update, params: { id: worker.id, suspended: true } }

    it do
      expect(response).to redirect_to(workers_path)

      expect(assigns(:worker).suspended).to be_truthy
    end
  end
end
