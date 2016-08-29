require 'rails_helper'

module Kuroko2
  describe 'Check if settings is loaded' do
    it 'loads custom tasks' do
      expect(Workflow::Node::TASK_REGISTORY).to have_key(:custom_task1)
      expect(Workflow::ScriptParser.new('custom_task1:').parse).to be_a(Workflow::Node)
    end
  end
end
