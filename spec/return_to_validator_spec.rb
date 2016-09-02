require 'rails_helper'

RSpec.describe Kuroko2::ReturnToValidator do
  let(:validator) { described_class }

  describe '.valid?' do
    it 'accepts a valid path' do
      expect(validator).to be_valid('/users/1')
    end

    it 'rejects absolute URI' do
      expect(validator).to_not be_valid('http://example.net')
    end

    it 'rejects protocol-relative URI' do
      expect(validator).to_not be_valid('//example.net')
    end

    it 'rejects non-URI' do
      expect(validator).to_not be_valid(nil)
      expect(validator).to_not be_valid('http:')
    end

    it 'rejects path starting with @' do
      expect(validator).to_not be_valid('@example.net')
    end
  end
end
