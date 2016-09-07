require 'rails_helper'

RSpec.describe "Login with google oauth2", type: :feature do
  before do
    mock_omni_auth_google_oauth2
  end

  it 'signs in and signs out' do
    visit kuroko2_path
    click_on('Sign in with Google')
    expect(page.current_path).to eq(kuroko2_path)
    expect(page).to have_content('Favorite Job Definitions')

    click_on('Sign out')
    expect(page).to have_content('Please sign in with Google account.')
  end
end
