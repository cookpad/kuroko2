require 'rails_helper'

describe 'job_instances' do
  let(:service_name) { :test_clinet_name }
  let(:secret_key)   { 'secret_key' }
  let(:result) { JSON.parse(response.body) }
  let(:env) do
    {
      accept: 'application/json',
      authorization: "Basic #{Base64.encode64("#{service_name}:#{secret_key}")}",
    }
  end
  let(:definition) do
    create(:job_definition, script: 'execute: bundle exec rake test:execute', api_allowed: true)
  end

  before do
    allow(Kuroko2.config.api_basic_authentication_applications).to receive(service_name).
      and_return(secret_key)
  end

  describe 'GET /v1/definitions/:job_definition_name/instances/:job_instance_id' do
    context 'with job_instance working' do
      let(:instance) { create(:job_instance, job_definition: definition, finished_at: nil, error_at: nil, canceled_at: nil) }

      it 'returns "working" as status' do
        get "/v1/definitions/#{definition.id}/instances/#{instance.id}", {}, env
        expect(response.status).to eq(200)
        expect(result).to eq({
          'id'     => instance.id,
          'status' => 'working',
        })
      end
    end

    context 'with job_instance succeeded' do
      let(:instance) { create(:job_instance, job_definition: definition, finished_at: Time.now, error_at: nil, canceled_at: nil) }

      it 'returns "success" as status' do
        get "/v1/definitions/#{definition.id}/instances/#{instance.id}", {}, env
        expect(response.status).to eq(200)
        expect(result).to eq({
          'id'     => instance.id,
          'status' => 'success',
        })
      end
    end
  end

  describe 'POST /v1/definitions/:job_definition_name/instances' do
    let(:params) { {} }

    it 'creates a job_instance' do
      expect {
        post "/v1/definitions/#{definition.id}/instances", params, env
      }.to change {
        definition.job_instances.count
      }.by(1)
      expect(definition.job_instances.last.script).to eq(definition.script)
      expect(result).to match({
        'id' => a_kind_of(Integer),
        'status' => 'working',
      })
    end

    context 'given env parameter' do
      let(:env_vars) do
        { 'JOB_NAME' => 'TestJob', 'MESSAGE' => %q{["it's a job"]} }
      end
      let(:params) { { env: env_vars } }

      it 'creates a job_instance with env task' do
        expect {
          post "/v1/definitions/#{definition.id}/instances", params, env
        }.to change {
          definition.job_instances.count
        }.by(1)
        expect(definition.job_instances.last.script).to eq(<<-SCRIPT.strip_heredoc.rstrip)
          env: JOB_NAME='TestJob'
          env: MESSAGE='["it\\'s a job"]'
          #{definition.script}
        SCRIPT
      end
    end

    context 'when job_definition is not api_allowed' do
      let(:definition) do
        create(:job_definition, script: 'execute: bundle exec rake test:execute', api_allowed: false)
      end

      it 'does not create a job_instance' do
        expect {
          post "/v1/definitions/#{definition.id}/instances", params, env
        }.to_not change {
          definition.job_instances.count
        }
        expect(response.status).to eq(403)
      end
    end
  end
end
