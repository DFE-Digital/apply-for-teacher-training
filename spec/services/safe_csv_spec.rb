require 'rails_helper'

RSpec.describe SafeCSV do
  describe '.sanitise' do
    it 'sanitises an array of values' do
      expect(
        SafeCSV.sanitise([123, 'hello', '=(A1,A6)']),
      ).to eq(
        [123, 'hello', '.=(A1,A6)'],
      )
    end

    it 'sanitises a single value' do
      expect(SafeCSV.sanitise('=(A1,A6)')).to eq('.=(A1,A6)')
    end
  end

  describe '.generate' do
    it 'works with a header row' do
      csv = SafeCSV.generate([[123, 'Bob'], [456, '=Alice()']], %w[id name])
      expect(csv).to eq "id,name\n123,Bob\n456,.=Alice()\n"
    end

    it 'works without a header row' do
      csv = SafeCSV.generate([[123, 'Bob'], [456, '=Alice()']])
      expect(csv).to eq "123,Bob\n456,.=Alice()\n"
    end
  end
end
