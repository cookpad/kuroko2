require 'rails_helper'

module Kuroko2
  describe 'Check if settings is loaded' do
    it 'loads custom tasks' do
      expect(Workflow::Node::TASK_REGISTORY.has_key?(:custom_task1)).to eq(true)
      expect(Workflow::ScriptParser.new('custom_task1:').parse.class).to eq(Workflow::Node)
    end
  end
end
