require 'rails_helper'

describe JobDefinitionsHelper do
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
        LGTM :+1:
      EOF
    end

    it { is_expected.to match %r(<h1>Title</h1>) }
    it { is_expected.to match %r(LGTM <img class="emoji") }
  end

end
