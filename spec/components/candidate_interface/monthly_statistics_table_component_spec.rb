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

  describe '#sort_value' do
    let(:statistics) do
      {
        'rows' =>
          [
            {
              'Age group' => 'Primary',
              'Recruited' => '0 to 4',
              'Conditions pending' => '0 to 4',
              'Received an offer' => '0 to 4',
              'Awaiting provider decisions' => 5,
              'Unsuccessful' => '0 to 4',
              'Total' => 11,
            },
          ],
        'column_totals' => [0, 1, 2, 5, 3, 11],
      }
    end

    it 'returns the correct data sort value for each count' do
      first_row = statistics['rows'].first

      component.data_from(first_row).map do |_status, count|
        if count == '0 to 4'
          expect(component.sort_value(count)).to eq('0')
        else
          expect(component.sort_value(count)).to eq count
        end
      end
    end
  end
end
