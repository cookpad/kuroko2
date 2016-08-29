require 'rails_helper'

describe 'stats api' do
  describe 'GET /v1/stats/instance' do
    before do
      create(:job_instance, job_definition: create(:job_definition))
      create(:job_instance, job_definition: create(:job_definition)).touch(:error_at)

      get '/v1/stats/instance'
    end

    it 'returns instance stats json' do
      expect(response.status).to eq(200)
      result = JSON.parse(response.body)
      expect(result).to eq({
        "kuroko2.job_instances.working" => 1,
        "kuroko2.job_instances.error" => 1,
      })
    end
  end

  describe 'GET /v1/stats/waiting_execution' do
    let!(:worker) { create(:worker) }

    before do
      create(
        :execution,
        job_definition: create(:job_definition),
        token: create(:token),
        started_at: nil,
        created_at: 4.minutes.ago,
      )

      get '/v1/stats/waiting_execution'
    end

    it 'returns waiting execution stats json' do
      expect(response.status).to eq(200)
      result = JSON.parse(response.body)
      expect(result).to eq({
        "kuroko2.executions.waiting.#{worker.queue}" => 1
      })
    end
  end
end
