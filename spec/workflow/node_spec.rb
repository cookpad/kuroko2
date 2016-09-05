require 'rails_helper'

module Kuroko2::Workflow
  describe Node do
    around do |example|
      Node.register(key: :node1, klass: Task::Base)
      Node.register(key: :node1_1, klass: Task::Base)
      Node.register(key: :node1_2, klass: Task::Base)
      Node.register(key: :node2, klass: Task::Base)

      example.run

      Node.deregister(:node1)
      Node.deregister(:node1_1)
      Node.deregister(:node1_2)
      Node.deregister(:node2)
    end

    let!(:root) do
      Node.new(:root).tap do |root|
        root.append_child(node1)
        root.append_child(node2)

        node1.append_child(node1_1)
        node1.append_child(node1_2)
      end
    end
    let(:node1) { Node.new(:node1) }
    let(:node1_1) { Node.new(:node1_1) }
    let(:node1_2) { Node.new(:node1_2) }
    let(:node2) { Node.new(:node2) }

    describe '#find' do
      it { expect(root.find('/0-node1')).to eq node1 }
      it { expect(root.find('/0-node1/0-node1_1')).to eq node1_1 }
      it { expect(root.find('/0-node1/1-node1_2')).to eq node1_2 }
      it { expect(root.find('/1-node2')).to eq node2 }

      it { expect { root.find('invalid query') }.to raise_error(AssertionError) }
    end

    describe '#next' do
      it { expect(root.next).to eq node1 }
      it { expect(node1.next).to eq node1_1 }
      it { expect(node1_1.next).to eq node1_2 }
      it { expect(node1_2.next).to eq node2 }
      it { expect(node2.next).to be_nil }
    end

    describe '#path' do
      it { expect(root.path).to eq '' }
      it { expect(node1.path).to eq '/0-node1' }
      it { expect(node1_1.path).to eq '/0-node1/0-node1_1' }
      it { expect(node1_2.path).to eq '/0-node1/1-node1_2' }
      it { expect(node2.path).to eq '/1-node2' }
    end

    describe '#to_script' do
      it { expect(node1.to_script).to eq "node1: \n  node1_1: \n  node1_2: \n" }
    end
  end
end
