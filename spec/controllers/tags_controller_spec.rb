require 'rails_helper'

describe Kuroko2::TagsController do
  routes { Kuroko2::Engine.routes }

  before { sign_in(users.first) }
  let(:users) { create_list(:user, 2) }

  describe '#destroy' do
    let(:tag) { create(:tag) }

    before do
      request.env['HTTP_REFERER'] = 'previous_page'
      delete(:destroy, params: { id: tag.id })
    end

    it 'is deleted' do
      expect(response).to redirect_to('previous_page')
      expect(Kuroko2::Tag.exists?(tag.id)).to be_falsey
      expect(Kuroko2::JobDefinitionTag.exists?(tag_id: tag.id)).to be_falsey
    end
  end
end
