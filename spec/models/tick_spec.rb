require 'rails_helper'

describe Kuroko2::Tick do
  describe '.fetch_then_update' do
    let(:prev_now) { Time.at(123456789) }
    let(:now) { Time.at(1234567890) }

    context 'without previous tick' do
      it do
        expect(Kuroko2::Tick.fetch_then_update(now)).to eq now
        expect(Kuroko2::Tick.first.at).to eq now
      end
    end
    context 'with previous tick' do
      before { create(:tick, at: prev_now) }

      it do
        expect(Kuroko2::Tick.fetch_then_update(now)).to eq prev_now
        expect(Kuroko2::Tick.first.at).to eq now
      end
    end
  end
end
