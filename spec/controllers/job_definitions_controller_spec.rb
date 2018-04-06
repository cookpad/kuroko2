require 'rails_helper'

describe Kuroko2::JobDefinitionsController do
  routes { Kuroko2::Engine.routes }

  before { sign_in }

  let(:definition) { create(:job_definition, :with_revisions) }

  describe '#index' do
    subject! { get :index }
    let!(:definitions) { create_list(:job_definition, 3) }

    it do
      expect(response).to have_http_status(:ok)
      expect(response).to render_template('index')

      expect(assigns(:definitions)).to eq definitions
    end
  end

  describe '#show' do
    subject! { get :show, params: { id: definition.id } }

    it do
      expect(response).to have_http_status(:ok)
      expect(response).to render_template('show')

      expect(assigns(:definition)).to eq definition
    end
  end

  describe '#new' do
    subject! { get :new }
    it do
      expect(response).to have_http_status(:ok)
      expect(response).to render_template('new')

      expect(assigns(:definition)).to be_new_record
    end

    context 'with dup_from params' do
      subject! { get :new, params: { dup_from: definition.id } }
      it do
        expect(response).to have_http_status(:ok)
        expect(response).to render_template('new')

        expect(assigns(:definition)).to be_new_record
        expect(assigns(:definition).name).to eq definition.name
        expect(assigns(:definition).admins).to eq definition.admins + [controller.current_user]
        expect(assigns(:definition).tags).to eq definition.tags
      end

      context 'with current_user and another admin user' do
        let!(:admin_user) { create(:user) }
        let!(:definition) { create(:job_definition, admins: [admin_user, controller.current_user]) }
        it do
          expect(response).to have_http_status(:ok)
          expect(response).to render_template('new')

          expect(assigns(:definition)).to be_new_record
          expect(assigns(:definition).name).to eq definition.name
          expect(assigns(:definition).admins).to match_array [admin_user, controller.current_user]
        end

        context 'with only another admin user' do
          let!(:definition) { create(:job_definition, admins: [admin_user]) }
          it do
            expect(response).to have_http_status(:ok)
            expect(response).to render_template('new')

            expect(assigns(:definition)).to be_new_record
            expect(assigns(:definition).name).to eq definition.name
            expect(assigns(:definition).admins).to match_array [admin_user, controller.current_user]
          end
        end
      end

      context 'with tags' do
        let!(:definition) { create(:job_definition, text_tags: 'First,Second') }
        it do
          expect(response).to have_http_status(:ok)
          expect(response).to render_template('new')

          expect(assigns(:definition)).to be_new_record
          expect(assigns(:definition).name).to eq definition.name
          expect(assigns(:definition).text_tags).to eq definition.text_tags
        end
      end

      context 'with invalid id' do
        subject! { get :new, params: { dup_from: 'invalid' } }
        it do
          expect(response).to have_http_status(:ok)
          expect(response).to render_template('new')

          expect(assigns(:definition)).to be_new_record
          expect(assigns(:definition).name).to be_blank
          expect(assigns(:definition).admins).to eq [controller.current_user]
        end
      end
    end
  end

  describe '#create' do
    subject! do
      post :create, params: { job_definition: { name: 'Job Definition', description: 'This is description', script: "noop:\n" }, admin_assignments: { user_id: [controller.current_user] } }
    end

    it do
      expect(response).to redirect_to(assigns(:definition))

      expect(assigns(:definition)).not_to be_new_record
      expect(assigns(:definition).admins).to eq [controller.current_user]
      expect(assigns(:definition).memory_expectancy).not_to be_nil
      expect(assigns(:definition).revisions.size).to eq 1
      expect(assigns(:definition).revisions.first.user).to eq controller.current_user
    end
  end

  describe '#edit' do
    subject! { get :edit, params: { id: definition.id } }

    it do
      expect(response).to have_http_status(:ok)
      expect(assigns(:definition)).to eq definition
    end
  end

  describe '#update' do
    let(:admin) { create(:user) }
    let(:script) { "noop:\n" }
    subject! do
      patch :update, params: { id: definition.id, job_definition: { name: 'Job Definition', description: 'This is description', script: script }, admin_assignments: { user_id: ["", admin.id] } }
    end

    it do
      expect(response).to redirect_to(assigns(:definition))

      expect(assigns(:definition)).not_to be_new_record
      expect(assigns(:definition).revisions.size).to eq 1
    end

    describe 'changes script' do
      let(:script) { "noop:\nnoop:\n" }
      it do
        expect(response).to redirect_to(assigns(:definition))

        expect(assigns(:definition)).not_to be_new_record
        expect(assigns(:definition).script).to eq script
        expect(assigns(:definition).revisions.size).to eq 2
        expect(assigns(:definition).revisions.first.script).to eq script
        expect(assigns(:definition).revisions.first.user).to eq controller.current_user
      end
    end
  end

  describe '#destroy' do
    subject! { delete :destroy, params: { id: definition.id } }

    it do
      expect(response).to redirect_to(job_definitions_path)

      expect(assigns(:definition)).to be_destroyed
    end
  end

end
