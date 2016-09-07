module FeatureSignInHelper
  def sign_in(user = create(:user))
    mock_omni_auth_google_oauth2(
      uid: user.uid,
      name: user.name,
      first_name: user.first_name,
      last_name: user.last_name,
      email: user.email,
      image: user.image,
    )

    visit kuroko2_path
    click_on('Sign in with Google')
  end

  def mock_omni_auth_google_oauth2(options = {})
    OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
      uid: options[:uid] || 'john@example.org',
      info: {
        name: options[:name] || "John Doe",
        first_name: options[:first_name] || "John",
        last_name: options[:last_name] || "Doe",
        email: options[:email] || "john@example.org",
        image: options[:image] || "https://img.example.org/john.doe.png",
      },
      credentials: {
        expires_at: options[:expires_at] || 1.month.since.to_i,
      }
    )
  end
end
