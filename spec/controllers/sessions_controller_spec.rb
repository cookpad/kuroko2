require 'rails_helper'

describe Kuroko2::SessionsController do
  routes { Kuroko2::Engine.routes }

  describe '#create' do
    let(:auth_hash) do
      {
        provider: 'google_oauth2',
        uid:      uid,
        info:     {
          name:       'John Doe',
          email:      'john@example.com',
          first_name: 'John',
          last_name:  'Doe',
          image:      'https://lh3.googleusercontent.com/url/photo.jpg'
        }
      }
    end
    let(:uid) { '123456789' }

    before do
      request.env['omniauth.auth'] = auth_hash
    end

    subject { get :create, provider: :google_oauth2 }

    context 'without user' do
      it 'creates new user and redirect to root_url' do
        is_expected.to redirect_to root_path
        expect(controller.current_user.uid).to eq uid
      end
    end

    context 'with user' do
      let!(:user) { create(:user, uid: uid) }

      it 'creates new user and redirect to root_url' do
        is_expected.to redirect_to root_path
        expect(controller.current_user.id).to eq user.id
        expect(controller.current_user.uid).to eq uid
      end
    end
  end

  describe '#new' do
    subject! { get :new }

    it { is_expected.to render_template('new') }
  end

  describe '#destroy' do
    subject! { delete :destroy }

    it { is_expected.to redirect_to(sign_in_path) }
  end

end
