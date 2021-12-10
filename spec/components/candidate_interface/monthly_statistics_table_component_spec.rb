require 'rails_helper'

RSpec.describe CandidateInterface::MonthlyStatisticsTableComponent do
  let(:caption) { 'Table data caption' }
  let(:statistics) do
    {
      'rows' =>
        [
          {
            'Age group' => 'Primary',
            'Recruited' => 1,
            'Conditions pending' => 0,
            'Received an offer' => 0,
            'Awaiting provider decisions' => 1,
            'Unsuccessful' => 1,
            'Total' => 3,
          },
        ],
      'column_totals' => [1, 0, 0, 1, 1, 3],
    }
  end

  subject(:component) { described_class.new(caption: caption, statistics: statistics) }

  describe '#rows' do
    it 'returns rows' do
      expect(component.rows).to eq([
        {
          'Age group' => 'Primary',
          'Recruited' => 1,
          'Conditions pending' => 0,
          'Received an offer' => 0,
          'Awaiting provider decisions' => 1,
          'Unsuccessful' => 1,
          'Total' => 3,
        },
      ])
    end
  end

  describe '#column_names' do
    it 'returns column names' do
      expect(component.column_names).to eq([
        'Age group',
        'Recruited',
        'Conditions pending',
        'Received an offer',
        'Awaiting provider decisions',
        'Unsuccessful',
        'Total',
      ])
    end
  end

  describe '#totals' do
    it 'returns totals' do
      expect(component.totals).to eq([1, 0, 0, 1, 1, 3])
    end
  end

  describe '#name_for' do
    it 'returns the row name' do
      first_row = statistics['rows'].first

      expect(component.name_for(first_row)).to eq('Primary')
    end
  end

  describe '#data_from' do
    it 'returns the row data' do
      first_row = statistics['rows'].first

      expect(component.data_from(first_row)).to eq({
        'Recruited' => 1,
        'Conditions pending' => 0,
        'Received an offer' => 0,
        'Awaiting provider decisions' => 1,
        'Unsuccessful' => 1,
        'Total' => 3,
      })
    end
  end
end
