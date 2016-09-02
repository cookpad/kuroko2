require 'rails_helper'

RSpec.describe Kuroko2::MemoryConsumptionLog do
  around {|example| Timecop.freeze(Time.now) { example.run } }

  describe described_class::Interval do
    describe '#reached?' do
      let(:interval) { described_class.new(base, count) }
      let(:base) { Time.now }

      context 'count = 0 and 2 seconds since' do
        let(:count) { 0 }
        let(:now) { 2.seconds.since.to_time }
        it { expect(interval.reached?(now)).to be_truthy }
      end

      context 'count = 10 and 2 minutes since' do
        let(:count) { 10 }
        let(:now) { 2.minutes.since.to_time }
        it { expect(interval.reached?(now)).to be_truthy }
      end

      context 'count = 100 and 31 minutes since' do
        let(:count) { 100 }
        let(:now) { 31.minutes.since.to_time }
        it { expect(interval.reached?(now)).to be_truthy }
      end
    end

    describe '#next' do
      it 'returns count-up-ed Interval' do
        a = described_class.new(Time.now)
        b = a.next
        expect(b).to be_a(described_class)

        diff = b.count - a.count
        expect(diff).to eq(1)
      end
    end

    it 'behaves as certain period interval with #reached? and #next' do
      a = described_class.new(Time.now, 100)
      expect(a.reached?(29.minutes.since.to_time)).to be_falsy
      expect(a.reached?(31.minutes.since.to_time)).to be_truthy
      b = a.next
      expect(b.reached?(59.minutes.since.to_time)).to be_falsy
      expect(b.reached?(61.minutes.since.to_time)).to be_truthy
    end
  end
end
