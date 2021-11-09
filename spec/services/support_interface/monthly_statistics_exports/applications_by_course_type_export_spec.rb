require 'rails_helper'

RSpec.describe SupportInterface::MonthlyStatisticsExports::ApplicationsByCourseTypeExport do
  describe '#data_for_export' do
    let(:data) {
      { rows: [
        { 'Course type' => 'Higher education', 'Recruited' => 15, 'Conditions pending' => 5, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 20 },
        { 'Course type' => 'Postgraduate teaching apprenticeship', 'Recruited' => 0, 'Conditions pending' => 15, 'Received an offer' => 5, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 20 },
        { 'Course type' => 'School-centred initial teacher training (SCITT)', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 15, 'Awaiting provider decisions' => 5, 'Unsuccessful' => 0, 'Total' => 20 },
        { 'Course type' => 'School Direct (fee-paying)', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 15, 'Unsuccessful' => 5, 'Total' => 20 },
        { 'Course type' => 'School Direct (salaried)', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 15, 'Total' => 15 },
      ],
        column_totals: [15, 20, 20, 20, 20, 95] }
    }

    before do
      monthly_statistics_double = instance_double(MonthlyStatistics::ByCourseType)
      allow(MonthlyStatistics::ByCourseType).to receive(:new).and_return monthly_statistics_double
      allow(monthly_statistics_double).to receive(:table_data).and_return data
    end

    it 'returns data for export in the desired state' do
      data_to_ouput = described_class.new.data_for_export

      expect(data_to_ouput).to eq(
        [
          { 'Course type' => 'Higher education', 'Recruited' => 15, 'Conditions pending' => 5, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 20 },
          { 'Course type' => 'Postgraduate teaching apprenticeship', 'Recruited' => 0, 'Conditions pending' => 15, 'Received an offer' => 5, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 20 },
          { 'Course type' => 'School-centred initial teacher training (SCITT)', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 15, 'Awaiting provider decisions' => 5, 'Unsuccessful' => 0, 'Total' => 20 },
          { 'Course type' => 'School Direct (fee-paying)', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 15, 'Unsuccessful' => 5, 'Total' => 20 },
          { 'Course type' => 'School Direct (salaried)', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 15, 'Total' => 15 },
          { 'Course type' => 'Total', 'Recruited' => 15, 'Conditions pending' => 20, 'Received an offer' => 20, 'Awaiting provider decisions' => 20, 'Unsuccessful' => 20, 'Total' => 95 },
        ],
      )
    end
  end
end
