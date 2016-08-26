require 'spec_helper'

RSpec.describe MemorySampler do
  describe 'get_by_pgid' do
    let!(:pid) { Process.spawn(*%w[sleep 10], pgroup: true) }

    it 'returns memory consumption' do
      expect(described_class.get_by_pgid(pid)).to be_kind_of(Integer)
    end
  end
end
