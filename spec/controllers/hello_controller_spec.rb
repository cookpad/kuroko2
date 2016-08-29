require 'rails_helper'

describe Kuroko2::HelloController do
  routes { Kuroko2::Engine.routes }

  describe '#revision' do
    subject! { get :revision }

    it do
      expect(response).to have_http_status(:ok)
      expect(response.content_type).to eq 'text/plain'
    end
  end
end
