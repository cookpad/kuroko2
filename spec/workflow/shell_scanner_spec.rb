require 'spec_helper'

module Kuroko2::Workflow
  describe ShellScanner do
    subject(:scanner) { ShellScanner.new(text) }

    describe '#strip_comment' do
      let(:text) { 'foo # bar' }

      it 'strips text after #' do
        expect(scanner.strip_comment).to eq('foo ')
      end

      context 'given nil' do
        let(:text) { nil }

        it 'returns nil' do
          expect(scanner.strip_comment).to eq(nil)
        end
      end

      context 'given string literal including #' do
        let(:text) { 'FOO="b\"ar#baz" # comment' }

        it 'preserves # in string literal' do
          expect(scanner.strip_comment).to eq('FOO="b\"ar#baz" ')
        end
      end

      context 'given string literal including # in single quotes' do
        let(:text) { %q[FOO='b\'ar#baz' # comment] }

        it 'preserves # in string literal' do
          expect(scanner.strip_comment).to eq(%q[FOO='b\'ar#baz' ])
        end
      end

      context 'given unmatched quote' do
        let(:text) { %q["' # foo] }

        it 'returns text until #' do
          expect(scanner.strip_comment).to eq(%q["' ])
        end
      end
    end
  end
end
