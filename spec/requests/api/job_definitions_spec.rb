require 'rails_helper'

describe 'job_definitions' do
  let(:service_name) { :test_client_name }
  let(:secret_key) { 'secret_key' }
  let(:env) do
    {
      accept: 'application/json',
      authorization: "Basic #{Base64.encode64("#{service_name}:#{secret_key}")}",
    }
  end
  let(:result) { JSON.parse(response.body) }

  describe 'GET /v1/definitions' do
    context "listing all definitions" do
      let!(:job_definition) do
        create(
          :job_definition,
          name: "My awsome job",
          description: "This is great",
          script: 'noop: rake make:awesome',
        )
      end

      before do
        create_list(:job_definition, 5, script: 'noop:')
      end

      it 'lists all definitions' do
        get "/v1/definitions", env: env
        expect(result.length).to eq 6
        expect(result.first).to eq(
          "id" => job_definition.id,
          "name" => job_definition.name,
          "description" => job_definition.description,
          "script" => job_definition.script,
          "tags" => [],
          "cron"=>[],
        )
      end
    end

    context "listing tagged definitions" do
      let(:foo) { Kuroko2::Tag.create(name: "foo") }
      let(:bar) { Kuroko2::Tag.create(name: "bar") }

      before do
        create_list(:job_definition, 2, script: 'noop:', tags: [foo])
        create_list(:job_definition, 3, script: 'noop:', tags: [bar])
        create_list(:job_definition, 2, script: 'noop:', tags: [foo, bar])
        create_list(:job_definition, 3, script: 'noop:')
      end

      it 'lists the definitions with specified tags' do
        get "/v1/definitions", env: env, params: { tags: ["foo"] }
        expect(result.length).to eq 4
      end

      it 'lists the definitions with several tags' do
        get "/v1/definitions", env: env, params: { tags: ["foo", "bar"] }
        expect(result.length).to eq 2
      end
    end
  end

  describe 'POST /v1/definitions' do

    let(:user) do
      create(:user)
    end

    context 'with valid parameters' do
      let(:params) do
        {
          name: "test",
          description: "description",
          script: "noop:",
          notify_cancellation: 1,
          hipchat_room: "",
          hipchat_notify_finished: 1,
          suspended: false,
          prevent_multi: 1,
          hipchat_additional_text: "",
          api_allowed: 1,
          slack_channel: "",
          webhook_url: "",
          user_id: [user.id],
        }
      end

      it 'creates a new definition' do
        expect {
          post "/v1/definitions", params: params, env: env
        }.to change {
          Kuroko2::JobDefinition.count
        }.by(1)
        expect(result['name']).to eq(params[:name])
        expect(result['description']).to eq(params[:description])
        expect(result['script']).to eq(params[:script])
        expect(response.status).to eq(201)
      end
    end

    context 'with tags' do
      let(:params) do
        {
          name: "test",
          description: "description",
          script: "noop:",
          notify_cancellation: 1,
          hipchat_room: "",
          hipchat_notify_finished: 1,
          suspended: false,
          prevent_multi: 1,
          hipchat_additional_text: "",
          tags: ["awesome", "sauce"],
          api_allowed: 1,
          slack_channel: "",
          webhook_url: "",
          user_id: [user.id],
        }
      end

      it 'creates the new tags' do
        expect {
          post "/v1/definitions", params: params, env: env
        }.to change {
          Kuroko2::Tag.count
        }.by(2)

        expect(response.status).to eq(201)
        expect(result['name']).to eq(params[:name])
        expect(result['description']).to eq(params[:description])
        expect(result['script']).to eq(params[:script])
        expect(result['tags']).to eq ["awesome", "sauce"]
      end

      context 'with a preexisiting tag' do
        before do
          Kuroko2::Tag.create(name: "awesome")
        end

        it 'only creates the tag the does not exist' do
          expect {
            post "/v1/definitions", params: params, env: env
          }.to change {
            Kuroko2::Tag.count
          }.by(1)

          expect(result['name']).to eq(params[:name])
          expect(result['description']).to eq(params[:description])
          expect(result['script']).to eq(params[:script])
          expect(result['tags']).to eq ["awesome", "sauce"]
        end

      end
    end

    context 'updating a schedule' do
      it 'updates the job_schedules' do
        params = {
          name: "test",
          description: "description",
          script: "noop:",
          user_id: [user.id],
          cron: ["0 0 1,15 * *", "0 */7 * * *"],
        }

        expect {
          post "/v1/definitions", params: params, env: env
        }.to change {
          Kuroko2::JobSchedule.count
        }.by(2)


        expect(response.status).to eq(201)

        params[:cron] = ["0 0 1 * *"]
        put "/v1/definitions/#{result['id']}", params: params, env: env
        expect(response.status).to eq(204)
        expect(Kuroko2::JobSchedule.count).to eq 1
      end
    end

    context 'with schedules' do
      let(:params) do
        {
          name: "test",
          description: "description",
          script: "noop:",
          user_id: [user.id],
          cron: ["0 0 1,15 * *", "0 */7 * * *", "0 0 * * *"],
        }
      end

      it 'creates the schedule' do
        expect {
          post "/v1/definitions", params: params, env: env
        }.to change {
          Kuroko2::JobSchedule.count
        }.by(3)

        expect(response.status).to eq(201)
        expect(result['name']).to eq(params[:name])
        expect(result['description']).to eq(params[:description])
        expect(result['script']).to eq(params[:script])
        expect(result['cron']).to match_array(params[:cron])
      end

      context 'an invalid schedule' do
        let(:params) do
          {
            name: "test",
            description: "description",
            script: "noop:",
            user_id: [user.id],
            cron: ["hotdogs"],
          }
        end

        it 'errors' do
          post "/v1/definitions", params: params, env: env
          expect(response.status).to eq(422)
          expect(result["message"]).to eq "hotdogs: Cron is invalid"
        end
      end
    end

    context 'with invalid parameters' do
      let(:params) do
        {
          description: "description",
          script: "noop:",
          notify_cancellation: 1,
          hipchat_room: "",
          hipchat_notify_finished: 1,
          suspended: false,
          prevent_multi: 1,
          hipchat_additional_text: "",
          api_allowed: 1,
          slack_channel: "",
          webhook_url: "",
          user_id: [user.id],
        }
      end

      it 'returns Http Status: 422' do
        post "/v1/definitions", params: params, env: env
        expect(response.status).to eq(422)
      end
    end
  end

  describe 'GET /v1/definitions/:id' do
    let(:tag) { Kuroko2::Tag.create(name: "taggy-mc-tagface") }
    let(:schedule) { create(:job_schedule) }
    let(:definition) do
      create(:job_definition, script: 'noop:', api_allowed: true, tags: [tag], job_schedules: [schedule])
    end

    it 'returns a definition' do
      get "/v1/definitions/#{definition.id}", params: {}, env: env
      expect(result).to eq(
        {
          'id' => definition.id,
          'name' => definition.name,
          'description' => definition.description,
          'script' => definition.script,
          'tags' => ['taggy-mc-tagface'],
          'cron' => [schedule.cron],
        }
      )
      expect(response.status).to eq(200)
    end
  end

  describe 'PUT /v1/definitions/:id' do
    let(:definition) do
      create(:job_definition, script: 'noop:', api_allowed: true)
    end

    context 'with valid parameters' do
      let(:params) do
        {
          name: "test",
          description: "description",
          script: "echo: Hello",
          notify_cancellation: 1,
          hipchat_room: "",
          hipchat_notify_finished: 1,
          suspended: false,
          prevent_multi: 1,
          hipchat_additional_text: "",
          api_allowed: 1,
          slack_channel: "",
          webhook_url: "",
        }
      end

      it 'updates a definition' do
        put "/v1/definitions/#{definition.id}", params: params, env: env
        expect(response.status).to eq(204)
      end
    end

    context 'with tags' do
      let(:params) do
        {
          name: "test",
          description: "description",
          script: "echo: Hello",
          notify_cancellation: 1,
          hipchat_room: "",
          hipchat_notify_finished: 1,
          suspended: false,
          prevent_multi: 1,
          hipchat_additional_text: "",
          api_allowed: 1,
          slack_channel: "",
          webhook_url: "",
          tags: ["new-tag"]
        }
      end

      it 'adds the tags' do
        expect {
          put "/v1/definitions/#{definition.id}", params: params, env: env
        }.to change {
          Kuroko2::Tag.count
        }.by(1)
        expect(response.status).to eq(204)
        expect(definition.tags.pluck(:name)).to eq ["new-tag"]
      end
    end

    context 'with invalid parameters' do
      let(:params) do
        {
          name: "test",
          description: "description",
          script: "noop",
          notify_cancellation: 1,
          hipchat_room: "",
          hipchat_notify_finished: 1,
          suspended: false,
          prevent_multi: 1,
          hipchat_additional_text: "",
          api_allowed: 1,
          slack_channel: "",
          webhook_url: "",
        }
      end

      it 'returns Http Status: 422' do
        put "/v1/definitions/#{definition.id}", params: params, env: env
        expect(response.status).to eq(422)
      end
    end

    context 'with a undefined definition' do
      let(:params) do
        {
          name: "test",
          description: "description",
          script: "echo: Hello",
          notify_cancellation: 1,
          hipchat_room: "",
          hipchat_notify_finished: 1,
          suspended: false,
          prevent_multi: 1,
          hipchat_additional_text: "",
          api_allowed: 1,
          slack_channel: "",
          webhook_url: "",
        }
      end

      it 'returns Http Status: 404' do
        put "/v1/definitions/#{definition.id + 1}", params: params, env: env
        expect(response.status).to eq(404)
      end
    end
  end

  describe 'DELETE /v1/definitions/:id' do
    let!(:definition) do
      create(:job_definition, script: 'noop:')
    end

    before do
      create_list(:job_definition, 2, script: 'noop:')
    end

    it 'deletes the job' do
      expect do
        delete "/v1/definitions/#{definition.id}", env: env
      end.to change { Kuroko2::JobDefinition.count }.by(-1)
      expect(Kuroko2::JobDefinition.where(id: definition.id)).to be_empty
      expect(response.status).to eq(204)
    end

    it 'errors when trying to delete a job_definition that does not exist' do
      definition.destroy

      delete "/v1/definitions/#{definition.id}", env: env
      expect(response.status).to eq(404)
    end
  end
end
