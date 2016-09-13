require 'rails_helper'

RSpec.describe "Show list of workers", type: :feature do

  let(:user) { create(:user) }
  let(:job_definition) do
    create(:job_definition_with_instances, script: <<-EOF.strip_heredoc)
      execute: echo Hello!
    EOF
  end

  let(:shell) { Kuroko2::Command::Shell.new(hostname: 'rspec', worker_id: 1, worker: worker) }
  let(:token) { job_definition.job_instances.first.tokens.first }
  let!(:worker) { create(:worker) }
  let(:workflow) { Kuroko2::Workflow::Engine.new }

  before do
    workflow.process(token)
    workflow.process(token)
    sign_in(user)
  end

  it 'shows execution jobs on the worker', js: true do
    visit kuroko2.workers_path
    expect(page).to have_selector('#workers table tbody tr', count: 2)
    expect(page).not_to have_content('echo Hello!')

    worker.update_column(:execution_id, token.execution.id)

    visit kuroko2.workers_path
    expect(page).to have_selector('#workers table tbody tr', count: 2)
    expect(page).to have_content('echo Hello!')
    expect(page).to have_selector('#workers table tbody tr td .btn', text: 'Details', count: 1)

    worker.update_column(:execution_id, token.execution.id)
    token.execution.finish(output: '', exit_status: 1)
    worker.update_column(:execution_id, nil)

    visit kuroko2.workers_path
    expect(page).to have_selector('#workers table tbody tr', count: 2)
    expect(page).not_to have_content('echo Hello!')
    expect(page).to have_selector('#workers table tbody tr td .btn', text: 'Details', count: 0)
  end
end
