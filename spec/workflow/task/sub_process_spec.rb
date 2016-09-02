require 'rails_helper'

module Kuroko2::Workflow::Task
  describe SubProcess do
    let(:definition) { create(:job_definition) }
    let(:sub_definition) { create(:job_definition) }

    let(:instance) do
      create(:job_instance, job_definition: definition).tap do |instance|
        instance.tokens.first.destroy
      end
    end

    let(:node) { Kuroko2::Workflow::Node.new(:sub_process, sub_definition.id.to_s) }
    let(:token) { create(:token, job_definition: definition, job_instance: instance) }

    let(:sub_instance) { sub_definition.job_instances.first }

    describe '#execute' do
      subject(:task) { SubProcess.new(node, token) }

      it do
        expect(task.execute).to eq :pass
        expect(Kuroko2::Token.count).to eq 2
        expect(task.execute).to eq :pass

        sub_instance.touch(:finished_at)
        expect(task.execute).to eq :next
      end
    end
  end
end
