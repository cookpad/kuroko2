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
          text_tags: "",
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
          text_tags: "",
          api_allowed: 1,
          slack_channel: "",
          webhook_url: "",
          user_id: [user.id],
        }
      end

      it 'returns Http Status: 400' do
        post "/v1/definitions", params: params, env: env
        expect(response.status).to eq(400)
      end
    end
  end

  describe 'GET /v1/definitions/:id' do
    let(:definition) do
      create(:job_definition, script: 'noop:', api_allowed: true)
    end

    it 'returns a definition' do
      get "/v1/definitions/#{definition.id}", params: {}, env: env
      expect(result).to eq(
        {
          'id' => definition.id,
          'name' => definition.name,
          'description' => definition.description,
          'script' => definition.script
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
          text_tags: "",
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

    context 'with invalid parameters' do
      let(:params) do
        {
          name: "test",
          description: "description",
          script: nil,
          notify_cancellation: 1,
          hipchat_room: "",
          hipchat_notify_finished: 1,
          suspended: false,
          prevent_multi: 1,
          hipchat_additional_text: "",
          text_tags: "",
          api_allowed: 1,
          slack_channel: "",
          webhook_url: "",
        }
      end

      it 'updates a definition' do
        expect {
          put "/v1/definitions/#{definition.id}", params: params, env: env
        }.to raise_error
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
          text_tags: "",
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
end
