require 'rails_helper'

describe User do
  describe '#google_account?' do
    subject { user.google_account? }

    context 'provider is google_oauth2' do
      let(:user) { create(:user, provider: 'google_oauth2') }
      it { is_expected.to be_truthy }
    end

    context 'provider is not google_oauth2' do
      let(:user) { create(:user, provider: 'group_email') }
      it { is_expected.to be_falsey }
    end
  end
end
