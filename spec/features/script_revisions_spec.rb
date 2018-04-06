require 'rails_helper'

describe 'Shows job definition revisions', type: :feature do
  before { sign_in }

  let!(:definition) { create(:job_definition, script: "noop:\n") }
  before do
    1.upto(3) { |i| definition.update_and_record_revision(script: "noop:\n" * i) }
  end

  it do
    visit kuroko2.job_definition_path definition
    expect(page).to have_content('Job Definition Details')

    click_on 'Show script revisions'

    expect(page).to have_content('Script Revisions')
    expect(page).to have_selector('.diff', count: 3)
  end
end
