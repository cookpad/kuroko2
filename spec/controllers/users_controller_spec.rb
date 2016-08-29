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

    subject! { get :show, id: user.id }

    it do
      expect(assigns(:user)).to eq user
      expect(assigns(:definitions)).to include job_definition
    end
  end

  describe '#create' do
    let(:name) { 'Test Users' }
    let(:email) { 'test@cookpad.com' }

    subject! { post(:create, user: { name: name, email: email }) }

    it { expect(response).to redirect_to(users_path) }
  end

  describe '#destroy' do
    let(:user) { users.last }
    subject! { delete(:destroy, id: user.id) }

    it do
      expect(response).to redirect_to(users_path)
      expect(User.exists?(user.id)).to be_falsey
    end
  end
end
