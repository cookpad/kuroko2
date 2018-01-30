require 'rails_helper'

describe 'Shows execution histories', type: :feature do
  before { sign_in }

  let!(:worker) { create(:worker, hostname: 'rspec') }
  let(:job_definition) { create(:job_definition) }
  let!(:histories) { create_list(:execution_history, 3, job_definition: job_definition) }

  it 'shows list of execution histories' do
    visit kuroko2.workers_path
    expect(page).to have_content('Kuroko Workers')
    expect(page).to have_content('rspec')
    expect(page).to have_content('@default')

    click_on 'rspec'

    expect(page).to have_content('Execution Histories')
    expect(page).to have_selector('#execution-histories table tbody tr', count: 3)
    expect(page).to have_content('rspec')
    expect(page).to have_content('@default')
    expect(page).to have_content(job_definition.name)
  end

  it 'shows timeline of execution histories' do
    visit kuroko2.execution_histories_path(hostname: 'rspec')

    expect(page).to have_content('Execution Histories')
    expect(page).to have_content('Show Timeline')

    click_on 'Show Timeline'

    expect(page).to have_content('Execution Timeline')
    expect(page).to have_content(job_definition.name)
  end
end
