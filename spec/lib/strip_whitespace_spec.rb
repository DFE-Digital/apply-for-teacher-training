require 'rails_helper'

RSpec.describe StripWhitespace do
  describe '.from_hash' do
    it 'removes whitespace characters from hash values' do
      hash = {
        key1: "\u180E\u200B\u200C\u200D\u2060\uFEFF value1 \u180E\u200B\u200C\u200D\u2060\uFEFF",
        key2: 'value2',
        'key3 ' => 'value3',
      }

      expect(described_class.from_hash(hash)).to eq(
        {
          key1: 'value1',
          key2: 'value2',
          'key3 ' => 'value3',
        },
      )
    end
  end

  describe '.from_string' do
    it 'removes whitespace characters from the string argument' do
      expect(
        described_class.from_string(
          "\u180E\u200B\u200C\u200D\u2060\uFEFF test \u180E\u200B\u200C\u200D\u2060\uFEFF",
        ),
      ).to eq('test')
    end
  end
end
