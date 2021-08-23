require 'rails_helper'

RSpec.describe SafeCSV do
  describe '.sanitise' do
    it 'sanitises an array of values' do
      expect(
        described_class.sanitise([123, 'hello', '=(A1,A6)']),
      ).to eq(
        [123, 'hello', '.=(A1,A6)'],
      )
    end

    it 'sanitises a single value' do
      expect(described_class.sanitise('=(A1,A6)')).to eq('.=(A1,A6)')
    end
  end

  describe '.generate' do
    it 'works with a header row' do
      csv = described_class.generate([[123, 'Bob'], [456, '=Alice()']], %w[id name])
      expect(csv).to eq "id,name\n123,Bob\n456,.=Alice()\n"
    end

    it 'works without a header row' do
      csv = described_class.generate([[123, 'Bob'], [456, '=Alice()']])
      expect(csv).to eq "123,Bob\n456,.=Alice()\n"
    end
  end

  describe '.generate_line' do
    it 'generates a sanitised line of CSV data' do
      csv_line = described_class.generate_line([456, '=Alice()'])
      expect(csv_line).to eq "456,.=Alice()\n"
    end
  end
end
