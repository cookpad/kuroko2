require 'rails_helper'

RSpec.describe "Launches a job instace and Management job instances on the web console", type: :feature do
  let(:user) { create(:user) }
  let(:job_definition) do
    create(:job_definition).tap do |d|
      d.admins << user
      d.save!
    end
  end

  let(:token) { job_definition.job_instances.first.tokens.first }
  let(:workflow) { Kuroko2::Workflow::Engine.new }

  before do
    sign_in(user)
  end

  it 'launches jobs and shows the instance status', js: true do
    visit kuroko2.job_definition_path(job_definition)

    expect(page).to have_content('Job Definition Details')
    expect(page).to have_content(job_definition.name)
    click_on 'Launch'

    expect(page).to have_selector('#launchAdHocModal .modal-dialog', visible: true)
    within '#launchAdHocModal .modal-dialog' do
      click_on 'Launch'
    end

    sleep 1
    expect(page).to have_content('Job Instance Details')
    expect(page).to have_selector('#instance-status .label', text: 'WORKING')

    visit kuroko2.working_job_instances_path
    expect(page).to have_content(job_definition.name)
    expect(page).to have_selector('table.table tbody tr', count: 2)

    visit kuroko2.job_definition_job_instance_path(job_definition, job_definition.job_instances.first)
    until token.status == Kuroko2::Token::FINISHED
      workflow.process(token)
    end

    sleep(2) # wait for setInterval, 2000
    expect(page).to have_selector('#instance-status .label', text: 'SUCCESS')
  end

  context 'if error occurred' do
    before do
      job_definition.job_instances.create
      workflow.process(token)
      token.job_instance.touch(:error_at)
      token.mark_as_failure
      token.save!
    end

    it 'skips the token', js: true do
      visit kuroko2.job_definition_job_instance_path(job_definition, job_definition.job_instances.first)
      expect(page).to have_selector('#instance-status .label', text: 'ERROR')

      click_on('Skip')

      sleep(2) # wait for setInterval, 2000
      expect(page).to have_selector('#instance-status .label', text: 'SUCCESS')
    end


    it 'retries the token', js: true do
      visit kuroko2.job_definition_job_instance_path(job_definition, job_definition.job_instances.first)
      expect(page).to have_selector('#instance-status .label', text: 'ERROR')

      click_on('Retry')
      token.reload

      until token.status == Kuroko2::Token::FINISHED
        workflow.process(token)
      end

      sleep(2) # wait for setInterval, 2000
      expect(page).to have_selector('#instance-status .label', text: 'SUCCESS')
    end

    it 'cancels the instance', js: true do
      visit kuroko2.job_definition_job_instance_path(job_definition, job_definition.job_instances.first)
      expect(page).to have_selector('#instance-status .label', text: 'ERROR')

      within '#instance' do
        click_on('Cancel')
      end

      sleep(2) # wait for setInterval, 2000
      expect(page).to have_selector('#instance-status .label', text: 'CANCEL')
    end
  end
end
