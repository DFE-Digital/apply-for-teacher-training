require 'rails_helper'

RSpec.describe SupportInterface::MonthlyStatisticsExports::ApplicationsByCourseAgeGroupExport do
  describe '#data_for_export' do
    let(:data) {
      {
        rows: [
          { 'Age group' => 'Primary', 'Recruited' => 20, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 20, 'Total' => 40 },
          { 'Age group' => 'Secondary', 'Recruited' => 0, 'Conditions pending' => 10, 'Received an offer' => 10, 'Awaiting provider decisions' => 10, 'Unsuccessful' => 0, 'Total' => 20 },
          { 'Age group' => 'Further education', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 10 },
        ],
        column_totals: [20, 10, 10, 10, 20, 70],
      }
    }

    before do
      monthly_statistics_double = instance_double(MonthlyStatistics::ByCourseAgeGroup)
      allow(MonthlyStatistics::ByCourseAgeGroup).to receive(:new).and_return monthly_statistics_double
      allow(monthly_statistics_double).to receive(:table_data).and_return data
    end

    it 'returns data for export in the desired state' do
      data_to_ouput = described_class.new.data_for_export

      expect(data_to_ouput).to eq(
        [
          { 'Age group' => 'Primary', 'Recruited' => 20, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 20, 'Total' => 40 },
          { 'Age group' => 'Secondary', 'Recruited' => 0, 'Conditions pending' => 10, 'Received an offer' => 10, 'Awaiting provider decisions' => 10, 'Unsuccessful' => 0, 'Total' => 20 },
          { 'Age group' => 'Further education', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 10 },
          { 'Age group' => 'Total', 'Recruited' => 20, 'Conditions pending' => 10, 'Received an offer' => 10, 'Awaiting provider decisions' => 10, 'Unsuccessful' => 20, 'Total' => 70 },
        ],
      )
    end
  end
end
