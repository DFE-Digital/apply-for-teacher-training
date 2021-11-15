require 'rails_helper'

RSpec.describe SupportInterface::MonthlyStatisticsExports::CandidatesByAgeGroupExport do
  describe '#data_for_export' do
    let(:data) {
      {
        rows: [
          { 'Age group' => '21 and under', 'Recruited' => 5, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 5 },
          { 'Age group' => '22', 'Recruited' => 0, 'Conditions pending' => 5, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 5 },
          { 'Age group' => '23', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 5, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 5 },
          { 'Age group' => '24', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 5, 'Unsuccessful' => 0, 'Total' => 5 },
          { 'Age group' => '25 to 29', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 5, 'Total' => 5 },
          { 'Age group' => '30 to 34', 'Recruited' => 5, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 5 },
          { 'Age group' => '35 to 39', 'Recruited' => 0, 'Conditions pending' => 5, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 5 },
          { 'Age group' => '40 to 44', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 5, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 5 },
          { 'Age group' => '45 to 49', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 5, 'Unsuccessful' => 0, 'Total' => 5 },
          { 'Age group' => '50 to 54', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 5, 'Total' => 5 },
          { 'Age group' => '55 to 59', 'Recruited' => 5, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 5 },
          { 'Age group' => '60 to 64', 'Recruited' => 0, 'Conditions pending' => 5, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 5 },
          { 'Age group' => '65 and over', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 5, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 5 },
        ],
        column_totals: [15, 15, 15, 10, 10, 65],
      }
    }

    before do
      monthly_statistics_double = instance_double(MonthlyStatistics::ByAgeGroup)
      allow(MonthlyStatistics::ByAgeGroup).to receive(:new).and_return monthly_statistics_double
      allow(monthly_statistics_double).to receive(:table_data).and_return data
    end

    it 'returns data for export in the desired state' do
      data_to_ouput = described_class.new.data_for_export

      expect(data_to_ouput).to eq(
        [
          { 'Age group' => '21 and under', 'Recruited' => 5, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 5 },
          { 'Age group' => '22', 'Recruited' => 0, 'Conditions pending' => 5, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 5 },
          { 'Age group' => '23', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 5, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 5 },
          { 'Age group' => '24', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 5, 'Unsuccessful' => 0, 'Total' => 5 },
          { 'Age group' => '25 to 29', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 5, 'Total' => 5 },
          { 'Age group' => '30 to 34', 'Recruited' => 5, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 5 },
          { 'Age group' => '35 to 39', 'Recruited' => 0, 'Conditions pending' => 5, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 5 },
          { 'Age group' => '40 to 44', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 5, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 5 },
          { 'Age group' => '45 to 49', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 5, 'Unsuccessful' => 0, 'Total' => 5 },
          { 'Age group' => '50 to 54', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 5, 'Total' => 5 },
          { 'Age group' => '55 to 59', 'Recruited' => 5, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 5 },
          { 'Age group' => '60 to 64', 'Recruited' => 0, 'Conditions pending' => 5, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 5 },
          { 'Age group' => '65 and over', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 5, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 5 },
          { 'Age group' => 'Total', 'Recruited' => 15, 'Conditions pending' => 15, 'Received an offer' => 15, 'Awaiting provider decisions' => 10, 'Unsuccessful' => 10, 'Total' => 65 },
        ],
      )
    end
  end
end
