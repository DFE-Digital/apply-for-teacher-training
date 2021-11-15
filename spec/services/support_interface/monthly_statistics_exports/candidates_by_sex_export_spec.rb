require 'rails_helper'

RSpec.describe SupportInterface::MonthlyStatisticsExports::CandidatesBySexExport do
  describe '#data_for_export' do
    let(:data) {
      { rows: [
        { 'Sex' => 'Female', 'Recruited' => 10, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 10 },
        { 'Sex' => 'Male', 'Recruited' => 0, 'Conditions pending' => 10, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 10 },
        { 'Sex' => 'Intersex', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 5, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 5 },
        { 'Sex' => 'Prefer not to say', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 5, 'Unsuccessful' => 5, 'Total' => 10 },
      ],
        column_totals: [10, 10, 5, 5, 5, 35] }
    }

    before do
      monthly_statistics_double = instance_double(MonthlyStatistics::BySex)
      allow(MonthlyStatistics::BySex).to receive(:new).and_return monthly_statistics_double
      allow(monthly_statistics_double).to receive(:table_data).and_return data
    end

    it 'returns data for export in the desired state' do
      data_to_ouput = described_class.new.data_for_export

      expect(data_to_ouput).to eq(
        [
          { 'Sex' => 'Female', 'Recruited' => 10, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 10 },
          { 'Sex' => 'Male', 'Recruited' => 0, 'Conditions pending' => 10, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 10 },
          { 'Sex' => 'Intersex', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 5, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 5 },
          { 'Sex' => 'Prefer not to say', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 5, 'Unsuccessful' => 5, 'Total' => 10 },
          { 'Sex' => 'Total', 'Recruited' => 10, 'Conditions pending' => 10, 'Received an offer' => 5, 'Awaiting provider decisions' => 5, 'Unsuccessful' => 5, 'Total' => 35 },
        ],
      )
    end
  end
end
