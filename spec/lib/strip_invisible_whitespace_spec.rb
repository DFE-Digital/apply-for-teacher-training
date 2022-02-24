require 'rails_helper'

RSpec.describe StripInvisibleWhitespace do
  describe '.from_hash' do
    it 'removes non-printable whitespace characters from hash values' do
      hash = {
        key1: "v\u180Ea\u200Bl\u200Cu\u200De\u20601\uFEFF",
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
          "\u180Et\u200Be\u200C\u200Ds\u2060t\uFEFF",
        ),
      ).to eq('test')
    end
  end
end
