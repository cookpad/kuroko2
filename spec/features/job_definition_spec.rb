require 'rails_helper'

RSpec.describe "Management job definitions", type: :feature do
  let(:user) { create(:user) }

  before do
    sign_in(user)
  end

  it 'creates/edit/destroy job_definition', js: true do
    visit kuroko2.root_path

    within '.sidebar-menu' do
      click_on 'Create New'
    end

    fill_in 'job_definition_name', with: 'test1'
    fill_in 'job_definition_description', with: 'description'
    fill_in 'job_definition_script', with: 'noop:'
    fill_in 'job_definition_text_tags', with: 'tag_1, common_tag'

    click_on 'Create Job definition'

    expect(page).to have_content('Job Definition Details')
    expect(page).to have_content('test1')

    click_on 'Edit Job definition'

    fill_in 'job_definition_name', with: 'test1-edit'
    click_on 'Update Job definition'

    expect(page).to have_content('Job Definition Details')
    expect(page).to have_content('test1-edit')

    click_on 'Destroy Job definition'
    expect(page).to have_content('All Job Definitions')
  end
end
