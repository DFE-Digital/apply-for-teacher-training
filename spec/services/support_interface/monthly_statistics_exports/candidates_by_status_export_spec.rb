require 'rails_helper'

RSpec.describe SupportInterface::MonthlyStatisticsExports::CandidatesByStatusExport do
  describe '#data_for_export' do
    let(:data) {
      {
        rows: [
          { 'Status' => 'Recruited', 'First application' => 2, 'Apply again' => 1, 'Total' => 3 },
          { 'Status' => 'Conditions pending', 'First application' => 1, 'Apply again' => 1, 'Total' => 2 },
          { 'Status' => 'Received an offer but not responded', 'First application' => 10, 'Apply again' => 4, 'Total' => 14 },
          { 'Status' => 'Awaiting provider decisions', 'First application' => 3, 'Apply again' => 2, 'Total' => 5 },
          { 'Status' => 'Declined an offer', 'First application' => 5, 'Apply again' => 0, 'Total' => 5 },
          { 'Status' => 'Withdrew an application', 'First application' => 3, 'Apply again' => 0, 'Total' => 3 },
          { 'Status' => 'Application rejected', 'First application' => 20, 'Apply again' => 8, 'Total' => 28 },
        ],
        column_totals: [44, 16, 60],
      }
    }

    before do
      monthly_statistics_double = instance_double(Publications::MonthlyStatistics::ByStatus)
      allow(Publications::MonthlyStatistics::ByStatus).to receive(:new).with(by_candidate: true).and_return monthly_statistics_double
      allow(monthly_statistics_double).to receive(:table_data).and_return data
    end

    it 'returns data for export in the desired state' do
      data_to_ouput = described_class.new.data_for_export

      expect(data_to_ouput).to eq(
        [
          { 'Status' => 'Recruited', 'First application' => 2, 'Apply again' => 1, 'Total' => 3 },
          { 'Status' => 'Conditions pending', 'First application' => 1, 'Apply again' => 1, 'Total' => 2 },
          { 'Status' => 'Received an offer but not responded', 'First application' => 10, 'Apply again' => 4, 'Total' => 14 },
          { 'Status' => 'Awaiting provider decisions', 'First application' => 3, 'Apply again' => 2, 'Total' => 5 },
          { 'Status' => 'Declined an offer', 'First application' => 5, 'Apply again' => 0, 'Total' => 5 },
          { 'Status' => 'Withdrew an application', 'First application' => 3, 'Apply again' => 0, 'Total' => 3 },
          { 'Status' => 'Application rejected', 'First application' => 20, 'Apply again' => 8, 'Total' => 28 },
          { 'Status' => 'Total', 'First application' => 44, 'Apply again' => 16, 'Total' => 60 },
        ],
      )
    end
  end
end
