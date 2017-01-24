require 'rails_helper'

RSpec.describe "User shows dashboard", type: :feature do
  let(:user) { create(:user) }

  before do
    sign_in(user)
  end

  context 'Favorite Jobs exists' do
    let(:job_definition) { create(:job_definition) }

    before do
      create(:star, job_definition: job_definition, user: user)
    end

    it 'shows favorite jobs' do
      visit kuroko2_path
      expect(page).to have_content(job_definition.name)
      expect(page).to have_selector('#definitions_list table tbody tr', count: 1)

      expect(page).to have_content('There are no working jobs.')
      expect(page).to have_title('Dashboard « Kuroko 2')
      expect(page).to have_selector('i.fa.fa-dashboard', text: '')
      expect(page).to have_selector('h1', text: /Dashboard/)
    end

    context 'if the favorite job is working' do
      before do
        job_definition.job_instances.create
      end

      it 'shows working jobs' do
        visit kuroko2_path
        expect(page).not_to have_content('There are no working jobs.')
        expect(page).to have_selector('#instances div table tr', count: 2)
      end
    end
  end

  context 'Some favorite jobs have tags', js: true do
    let(:common_tag) { 'common_tag' }

    before do
      10.times.each do |i|
        create(
          :star,
          job_definition: create(:job_definition).tap { |d|
            d.text_tags = "#{common_tag}, tag_#{i}"
            d.save!
          },
          user: user
        )
      end
    end

    it 'shows tags' do
      visit kuroko2_path
      expect(page).to have_content(common_tag)
      10.times.each do |i|
        expect(page).to have_content("tag_#{i}")
      end

      expect(page).to have_selector('#definitions_list table tbody tr', count: 10)
    end

    it 'selects tagged jobs' do
      visit kuroko2_path

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

    it 'deletes a tag' do
      visit kuroko2_path

      within '#tags' do
        page.find('#tag_list li:nth-child(2) .delete-tag').click
      end

      expect(page).not_to have_content('tag_0')
      expect(page).to have_selector('#tag_list ul li', count: 10)
    end
  end
end
