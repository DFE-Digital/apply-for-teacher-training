require 'rails_helper'

RSpec.describe SupportInterface::MonthlyStatisticsExports::ApplicationsByProviderAreaExport do
  describe '#data_for_export' do
    let(:data) {
      {
        rows: [
          { 'Area' => 'East', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 0 },
          { 'Area' => 'East Midlands', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 0 },
          { 'Area' => 'London', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 0 },
          { 'Area' => 'North East', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 0 },
          { 'Area' => 'North West', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 0 },
          { 'Area' => 'South East', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 0 },
          { 'Area' => 'South West', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 0 },
          { 'Area' => 'West Midlands', 'Recruited' => 1, 'Conditions pending' => 1, 'Received an offer' => 7, 'Awaiting provider decisions' => 15, 'Unsuccessful' => 10, 'Total' => 34 },
          { 'Area' => 'Yorkshire and The Humber', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 0 },
        ],
        column_totals: [1, 1, 7, 15, 10, 34],
      }
    }

    before do
      monthly_statistics_double = instance_double(Publications::MonthlyStatistics::ByProviderArea)
      allow(Publications::MonthlyStatistics::ByProviderArea).to receive(:new).and_return monthly_statistics_double
      allow(monthly_statistics_double).to receive(:table_data).and_return data
    end

    it 'returns data for export in the desired state' do
      data_to_ouput = described_class.new.data_for_export

      expect(data_to_ouput).to eq(
        [
          { 'Area' => 'East', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 0 },
          { 'Area' => 'East Midlands', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 0 },
          { 'Area' => 'London', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 0 },
          { 'Area' => 'North East', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 0 },
          { 'Area' => 'North West', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 0 },
          { 'Area' => 'South East', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 0 },
          { 'Area' => 'South West', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 0 },
          { 'Area' => 'West Midlands', 'Recruited' => 1, 'Conditions pending' => 1, 'Received an offer' => 7, 'Awaiting provider decisions' => 15, 'Unsuccessful' => 10, 'Total' => 34 },
          { 'Area' => 'Yorkshire and The Humber', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 0 },
          { 'Area' => 'Total', 'Recruited' => 1, 'Conditions pending' => 1, 'Received an offer' => 7, 'Awaiting provider decisions' => 15, 'Unsuccessful' => 10, 'Total' => 34 },
        ],
      )
    end
  end
end
