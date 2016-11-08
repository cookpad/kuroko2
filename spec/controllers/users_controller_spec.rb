require 'rails_helper'

describe Kuroko2::UsersController do
  routes { Kuroko2::Engine.routes }

  before { sign_in(users.first) }
  let(:users) { create_list(:user, 2) }

  describe '#index' do
    subject! { get :index }
    it { expect(assigns(:users).to_a).to eq users }

    context 'with groups parameter' do
      before do
        users.each {|u| u.update_attributes!(provider: 'group_mail') }
      end
      it { expect(assigns(:users).to_a).to eq users }
    end
  end

  describe '#show' do
    let(:user) { job_definition.admins.first }
    let(:job_definition) { create(:job_definition) }

    subject! { get :show, params: { id: user.id } }

    it do
      expect(assigns(:user)).to eq user
      expect(assigns(:definitions)).to include job_definition
    end
  end

  describe '#create' do
    let(:name) { 'Test Users' }
    let(:email) { 'test@example.com' }

    subject! { post(:create,  params: { user: { name: name, email: email } }) }

    it { expect(response).to redirect_to(users_path) }
  end

  describe '#edit' do
    let(:name) { 'Test Users' }
    let(:email) { 'test@example.com' }

    let(:provider) { Kuroko2::User::GROUP_PROVIDER }
    let(:user) do
      create(
        :user,
        name: 'name',
        email: 'initial@example.com',
        provider: provider,
      )
    end

    before { put(:update,  params: { id: user.id, user: { name: name, email: email } }) }

    it 'edits the name/email' do
      user = assigns(:user).reload
      expect(user.name).to eq(name)
      expect(user.email).to eq(email)
      expect(response).to redirect_to(user_path(user))
    end

    context 'if user is google account' do
      let(:provider) { Kuroko2::User::GOOGLE_OAUTH2_PROVIDER }

      it 'returns bad request' do
        expect(response).to have_http_status(:bad_request)
      end
    end
  end

  describe '#destroy' do
    let(:provider) { Kuroko2::User::GROUP_PROVIDER }
    let(:user) do
      create(
        :user,
        name: 'name',
        email: 'initial@example.com',
        provider: provider,
      )
    end

    before { delete(:destroy, params: { id: user.id }) }

    it do
      expect(response).to redirect_to(users_path)
      expect(Kuroko2::User.exists?(user.id)).to be_falsey
    end

    context 'if user is google account' do
      let(:provider) { Kuroko2::User::GOOGLE_OAUTH2_PROVIDER }

      it 'returns bad request' do
        expect(response).to have_http_status(:bad_request)
      end
    end
  end
end
