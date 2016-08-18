require 'rails_helper'

RSpec.describe MemoryExpectancy do
  let!(:definition) { create(:job_definition) }
  let!(:instance) { create(:job_instance, job_definition: definition) }
  let!(:expectancy) { described_class.create!(job_definition: definition) }

  describe 'memory expectancy calculation' do
    before { (1..10).each {|i| instance.log_memory_consumption(i) } }

    it 'logs consumptions then calculates expectancy' do
      expect(expectancy.expected_value).to eq(described_class::DEFAULT_VALUE)
      expectancy.calculate!
      expect(expectancy.reload.expected_value).not_to eq(described_class::DEFAULT_VALUE)
    end
  end

  describe '#calculate!' do
    before { (1..10).each {|i| instance.log_memory_consumption(i) } }

    it 'uses max consumption value' do
      expectancy.calculate!
      expect(expectancy.expected_value).to eq(10)
    end
  end
end
