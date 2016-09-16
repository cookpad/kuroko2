require 'rails_helper'

describe Kuroko2::JobTimelinesController do
  routes { Kuroko2::Engine.routes }

  let(:instance_num) { 2 }
  let(:definition) do
    create(
      :job_definition_with_instances,
      job_instances_count: instance_num,
      job_instances_token_status: Kuroko2::Token::FINISHED
    )
  end

  let(:target_user) { assigns(:_current_user) }

  before do
    sign_in
    definition.job_instances.first.update!(created_at: 1.week.ago)
    Kuroko2::Star.create!(job_definition: definition, user: target_user)
    definition.text_tags = 'test'
    definition.save!
  end

  describe '#index' do
    before { get :index }

    it do
      expect(response).to have_http_status(:ok)
      expect(response).to render_template('index')
      expect(assigns(:user)).to eq assigns(:_current_user)
    end
  end

  describe '#dataset' do
    context 'without parameters' do
      before { get :dataset, xhr: true }

      it do
        expect(response).to have_http_status(:ok)
        expect(assigns(:user)).to eq assigns(:_current_user)
        expect(assigns(:instances).size).to eq 1
      end
    end

    context 'with period parameter' do
      before { get :dataset, params: { period: period }, xhr: true }

      context 'with period is 1 hour' do
        let(:period) { '1h' }
        it { expect(assigns(:instances).size).to eq 1 }
      end

      context 'with period is 1 day' do
        let(:period) { '1d' }
        it { expect(assigns(:instances).size).to eq 1 }
      end

      context 'with period is 2 weeks' do
        let(:period) { '2w' }
        it { expect(assigns(:instances).size).to eq 2 }
      end
    end

    context 'with user_id parameter' do
      let(:target_user) { create(:user) }
      before { get :dataset, params: { user_id: target_user.id }, xhr: true }

      it do
        expect(response).to have_http_status(:ok)
        expect(assigns(:user)).to eq target_user
        expect(assigns(:instances).size).to eq 1
      end

      context 'if user is group user' do
        let(:group_user) { create(:user) }

        before do
          Kuroko2::AdminAssignment.create!(job_definition: definition, user: group_user)
          get :dataset, params: { user_id: group_user.id }, xhr: true
        end

        it do
          expect(response).to have_http_status(:ok)
          expect(assigns(:user)).to eq group_user
          expect(assigns(:instances).size).to eq 1
        end
      end
    end

    context 'with tag parameter' do
      let(:target_user) { create(:user) }
      before do
        get :dataset, params: { user_id: target_user.id, period: '2w', tag: ['test'] }, xhr: true
      end

      it do
        expect(response).to have_http_status(:ok)
        expect(assigns(:instances).size).to eq 2
      end

      context 'when tag does not exist' do
        before do
          get :dataset, params: { user_id: target_user.id, period: '2w', tag: ['test2'] }, xhr: true
        end

        it do
          expect(response).to have_http_status(:ok)
          expect(assigns(:instances).size).to eq 0
        end
      end
    end
  end
end
