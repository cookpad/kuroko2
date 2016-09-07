require 'rails_helper'

describe "Login with google oauth2", type: :feature do
  before do
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
      uid: 'john@example.org',
      info: {
        name:  "John Doe",
        first_name: "John",
        last_name: "Doe",
        email: "john@example.org",
        image: "https://img.example.org/john.doe.png",
      },
      credentials: {
        expires_at: 1.month.since.to_i,
      }
    )
  end

  it 'sigin and sign out' do
    visit kuroko2_path
    click_on('Sign in with Google')
    expect(page.current_path).to eq(kuroko2_path)
    expect(page).to have_content('Favorite Job Definitions')

    click_on('Sign out')
    expect(page).to have_content('Please sign in with Google account.')
  end
end
