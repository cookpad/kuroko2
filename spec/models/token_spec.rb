require 'rails_helper'

describe Token do
  describe '#cancelable?' do
    context 'without children' do
      context 'working' do
        subject! { create(:token, status: Token::WORKING) }

        it { is_expected.not_to be_cancelable }
      end
      context 'finished' do
        subject! { create(:token, status: Token::FINISHED) }

        it { is_expected.not_to be_cancelable }
      end
      context 'failure' do
        subject! { create(:token, status: Token::FAILURE) }

        it { is_expected.to be_cancelable }
      end
      context 'critical' do
        subject! { create(:token, status: Token::CRITICAL) }

        it { is_expected.not_to be_cancelable }
      end
    end

    context 'with children' do
      subject!(:parent) { create(:token, status: Token::WORKING) }

      context 'all children are working' do
        before { create(:token, parent_id: parent.id, status: Token::WORKING) }
        before { create(:token, parent_id: parent.id, status: Token::WORKING) }

        it { is_expected.not_to be_cancelable }
      end

      context 'working and failrue' do
        before { create(:token, parent_id: parent.id, status: Token::WORKING) }
        before { create(:token, parent_id: parent.id, status: Token::FAILURE) }

        it { is_expected.not_to be_cancelable }
      end

      context 'finished and failure' do
        before { create(:token, parent_id: parent.id, status: Token::FINISHED) }
        before { create(:token, parent_id: parent.id, status: Token::FAILURE) }

        it { is_expected.to be_cancelable }
      end

    end
  end
end
