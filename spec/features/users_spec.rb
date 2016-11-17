require 'rails_helper'

RSpec.describe "Users management", type: :feature do
  let(:user) { create(:user) }

  before do
    sign_in(user)
  end

  it 'shows users' do
    visit kuroko2.users_path
    expect(page).to have_selector('#users tbody tr', count: 1)
    expect(page).to have_content(user.name)

    click_on('View Details')
    expect(page).to have_content("##{user.id} #{user.name}")
  end

  it 'creates and edits group users' do
    visit kuroko2.users_path
    fill_in 'Name', with: 'Test Group User'
    fill_in 'Email', with: 'test_group_user@example.com'
    click_on 'Add mail address'

    expect(page).to have_selector('#users tbody tr', count: 2)
    expect(page).to have_content(user.name)
    expect(page).to have_content('Test Group User')

    within '.sidebar-menu' do
      click_on 'Groups'
    end

    expect(page).to have_selector('#users tbody tr', count: 1)
    expect(page).to have_content('Test Group User')

    visit kuroko2.users_path(target: 'group')
    click_on('View Details')
    click_on('Edit User')

    fill_in 'Name', with: 'Test Group User v2'
    fill_in 'Email', with: 'test_group_userv2@example.com'
    click_on('Update')

    expect(page).to have_content('Test Group User v2')
  end

  context 'A user has some tagged job_definitions', js: true do
    let(:common_tag) { 'common_tag' }

    before do
      10.times.each do |i|
        create(:job_definition).tap do |d|
          d.text_tags = "#{common_tag}, tag_#{i}"
          d.admins << user
          d.save!
        end
      end
    end

    it 'shows tags' do
      visit kuroko2.user_path(user.id)
      expect(page).to have_content(common_tag)
      10.times.each do |i|
        expect(page).to have_content("tag_#{i}")
      end

      expect(page).to have_selector('#definitions_list table tbody tr', count: 10)
    end

    it 'selects tagged jobs' do
      visit kuroko2.user_path(user.id)

      expect(page).to have_content(common_tag)

      within '#tags' do
        click_on(common_tag)
      end
      wait_for_ajax
      expect(page).to have_selector('#definitions_list table tbody tr', count: 10)

      within '#tags' do
        click_on("tag_1")
      end
      wait_for_ajax
      expect(page).to have_selector('#definitions_list table tbody tr', count: 1)

      within '#tags' do
        click_on("tag_1")
      end
      wait_for_ajax
      expect(page).to have_selector('#definitions_list table tbody tr', count: 10)
    end

    context 'if the favorite job is working' do
      before do
        user.assigned_job_definitions.first.job_instances.create
      end

      it 'shows working jobs' do
        visit kuroko2.user_path(user.id)
        expect(page).not_to have_content('There are no working jobs.')
        expect(page).to have_selector('#instances div table tr', count: 2)
      end
    end
  end
end
