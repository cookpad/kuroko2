require 'rails_helper'

describe Kuroko2::Token do
  describe '#cancelable?' do
    context 'without children' do
      context 'working' do
        subject! { create(:token, status: Kuroko2::Token::WORKING) }

        it { is_expected.not_to be_cancelable }
      end
      context 'finished' do
        subject! { create(:token, status: Kuroko2::Token::FINISHED) }

        it { is_expected.not_to be_cancelable }
      end
      context 'failure' do
        subject! { create(:token, status: Kuroko2::Token::FAILURE) }

        it { is_expected.to be_cancelable }
      end
      context 'critical' do
        subject! { create(:token, status: Kuroko2::Token::CRITICAL) }

        it { is_expected.not_to be_cancelable }
      end
    end

    context 'with children' do
      subject!(:parent) { create(:token, status: Kuroko2::Token::WORKING) }

      context 'all children are working' do
        before { create(:token, parent_id: parent.id, status: Kuroko2::Token::WORKING) }
        before { create(:token, parent_id: parent.id, status: Kuroko2::Token::WORKING) }

        it { is_expected.not_to be_cancelable }
      end

      context 'working and failrue' do
        before { create(:token, parent_id: parent.id, status: Kuroko2::Token::WORKING) }
        before { create(:token, parent_id: parent.id, status: Kuroko2::Token::FAILURE) }

        it { is_expected.not_to be_cancelable }
      end

      context 'finished and failure' do
        before { create(:token, parent_id: parent.id, status: Kuroko2::Token::FINISHED) }
        before { create(:token, parent_id: parent.id, status: Kuroko2::Token::FAILURE) }

        it { is_expected.to be_cancelable }
      end

    end
  end
end
