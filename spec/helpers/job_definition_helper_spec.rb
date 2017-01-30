require 'rails_helper'

describe Kuroko2::JobDefinitionsHelper do
  include Kuroko2::Engine.routes.url_helpers

  describe '#first_line' do
    subject { first_line(text) }

    let(:line) { 'First Line' }

    context 'multi line text' do
      let(:text) do
        <<-EOF.strip_heredoc
          #{line}

          Additional
        EOF
      end

      it { is_expected.to eq line }
    end

    context 'single line text' do
      let(:text) { line }

      it { is_expected.to eq line }
    end
  end

  describe '#markdown_format' do
    subject { markdown_format(text) }

    let(:text) do
      <<-EOF.strip_heredoc
        # Title
        LGTM
      EOF
    end

    it { is_expected.to match %r(<h1>Title</h1>) }
    it { is_expected.to match %r(LGTM) }
  end

  describe "#format_kuroko_script" do
    subject { format_kuroko_script(text) }
    let(:definition1) { create(:job_definition) }
    let(:definition2) { create(:job_definition) }
    let(:definition3) { create(:job_definition) }

    let(:text) do
      <<-EOF.strip_heredoc
        wait: #{definition1.id}/daily #{definition2.id}/daily timeout=100
        sub_process: #{definition3.id}
      EOF
    end

    it do
      expect(subject).to eq(<<-HTML.strip_heredoc)
        wait: <a href="/definitions/#{definition1.id}">#{definition1.id}/daily</a> <a href="/definitions/#{definition2.id}">#{definition2.id}/daily</a> timeout=100 <span class="note"># #{definition1.name}, #{definition2.name}</span>
        <a href="/definitions/#{definition3.id}">sub_process: #{definition3.id}</a> <span class="note"># #{definition3.name}</span>
      HTML
    end
  end
end
