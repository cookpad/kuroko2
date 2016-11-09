require 'rails_helper'

describe Kuroko2::SessionsController do
  routes { Kuroko2::Engine.routes }

  describe '#create' do
    let(:auth_hash) do
      OmniAuth::AuthHash.new(
        provider: 'google_oauth2',
        uid:      uid,
        info:     {
          name:       'John Doe',
          email:      'john@example.com',
          first_name: 'John',
          last_name:  'Doe',
          image:      'https://lh3.googleusercontent.com/url/photo.jpg'
        },
        extra: {
          id_info: {},
        },
      )
    end
    let(:uid) { '123456789' }

    before do
      request.env['omniauth.auth'] = auth_hash
    end

    subject { get :create, params: { provider: :google_oauth2 } }

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

    context 'with hd configured' do
      let(:configured_hd) { 'example.com' }

      before do
        allow(Kuroko2.config.app_authentication.google_oauth2.options).to receive_messages(hd: configured_hd)
      end

      context 'with valid hd' do
        before do
          auth_hash.extra.id_info.hd = configured_hd
        end

        it 'creates a new session' do
          get :create, params: { provider: :google_oauth2 }
          expect(response).to redirect_to(root_path)
          expect(controller.current_user.uid).to eq(uid)
        end
      end

      context 'with invalid hd' do
        before do
          auth_hash.extra.id_info.hd = 'example.net'
        end

        it 'rejects' do
          get :create, params: { provider: :google_oauth2 }
          expect(response).to have_http_status(403)
          expect(controller.current_user).to be_nil
        end
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
