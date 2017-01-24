require 'rails_helper'

RSpec.describe 'Management tags in job definitions view', type: :feature do
  let(:user) { create(:user) }

  before { sign_in(user) }

  context 'There are 3 tags', js: true do
    before do
      3.times.each { |i| create(:tag, name: "tag_#{i}") }
    end

    it 'shows tags' do
      visit kuroko2.root_path

      within '.sidebar-menu' do
        click_on 'All Job Definitions'
      end

      expect(page).to have_selector('#tag_list ul li', count: 3)
      expect(page).to have_content('tag_0')
      expect(page).to have_content('tag_1')
      expect(page).to have_content('tag_2')
    end

    it 'deletes a tag' do
      visit kuroko2.root_path

      within '.sidebar-menu' do
        click_on 'All Job Definitions'
      end

      within '#tags' do
        page.find('#tag_list li:first-child .delete-tag').click
      end

      expect(page).not_to have_content('tag_0')
      expect(page).to have_selector('#tag_list ul li', count: 2)
    end
  end
end
