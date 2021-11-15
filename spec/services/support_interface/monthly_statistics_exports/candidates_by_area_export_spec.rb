require 'rails_helper'

RSpec.describe SupportInterface::MonthlyStatisticsExports::CandidatesByAreaExport do
  describe '#data_for_export' do
    let(:data) {
      {
        rows: [
          { 'Area' => 'Channel Islands', 'Recruited' => 5, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 5 },
          { 'Area' => 'East Midlands', 'Recruited' => 5, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 5 },
          { 'Area' => 'Eastern', 'Recruited' => 5, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 5 },
          { 'Area' => 'Isle of Man', 'Recruited' => 0, 'Conditions pending' => 5, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 5 },
          { 'Area' => 'London', 'Recruited' => 0, 'Conditions pending' => 5, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 5 },
          { 'Area' => 'No region', 'Recruited' => 0, 'Conditions pending' => 5, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 5 },
          { 'Area' => 'North East', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 5, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 5 },
          { 'Area' => 'North West', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 5, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 5 },
          { 'Area' => 'Northern Ireland', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 5, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 5 },
          { 'Area' => 'Scotland', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 5, 'Total' => 5 },
          { 'Area' => 'South East', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 5, 'Total' => 5 },
          { 'Area' => 'South West', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 5, 'Total' => 5 },
          { 'Area' => 'Wales', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 5, 'Unsuccessful' => 0, 'Total' => 0 },
          { 'Area' => 'West Midlands', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 5, 'Unsuccessful' => 0, 'Total' => 0 },
          { 'Area' => 'Yorkshire and the Humber', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 5, 'Unsuccessful' => 0, 'Total' => 0 },
          { 'Area' => 'European Economic Area', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 0 },
          { 'Area' => 'Rest of the World', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 0 },
        ],
        column_totals: [15, 15, 15, 15, 15, 75],
      }
    }

    before do
      monthly_statistics_double = instance_double(MonthlyStatistics::ByArea)
      allow(MonthlyStatistics::ByArea).to receive(:new).and_return monthly_statistics_double
      allow(monthly_statistics_double).to receive(:table_data).and_return data
    end

    it 'returns data for export in the desired state' do
      data_to_ouput = described_class.new.data_for_export

      expect(data_to_ouput).to eq(
        [
          { 'Area' => 'Channel Islands', 'Recruited' => 5, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 5 },
          { 'Area' => 'East Midlands', 'Recruited' => 5, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 5 },
          { 'Area' => 'Eastern', 'Recruited' => 5, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 5 },
          { 'Area' => 'Isle of Man', 'Recruited' => 0, 'Conditions pending' => 5, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 5 },
          { 'Area' => 'London', 'Recruited' => 0, 'Conditions pending' => 5, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 5 },
          { 'Area' => 'No region', 'Recruited' => 0, 'Conditions pending' => 5, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 5 },
          { 'Area' => 'North East', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 5, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 5 },
          { 'Area' => 'North West', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 5, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 5 },
          { 'Area' => 'Northern Ireland', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 5, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 5 },
          { 'Area' => 'Scotland', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 5, 'Total' => 5 },
          { 'Area' => 'South East', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 5, 'Total' => 5 },
          { 'Area' => 'South West', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 5, 'Total' => 5 },
          { 'Area' => 'Wales', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 5, 'Unsuccessful' => 0, 'Total' => 0 },
          { 'Area' => 'West Midlands', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 5, 'Unsuccessful' => 0, 'Total' => 0 },
          { 'Area' => 'Yorkshire and the Humber', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 5, 'Unsuccessful' => 0, 'Total' => 0 },
          { 'Area' => 'European Economic Area', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 0 },
          { 'Area' => 'Rest of the World', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 0 },
          { 'Area' => 'Total', 'Recruited' => 15, 'Conditions pending' => 15, 'Received an offer' => 15, 'Awaiting provider decisions' => 15, 'Unsuccessful' => 15, 'Total' => 75 },
        ],
      )
    end
  end
end
