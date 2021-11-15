require 'rails_helper'

RSpec.describe SupportInterface::MonthlyStatisticsExports::ApplicationsByPrimarySpecialistSubjectExport do
  describe '#data_for_export' do
    let(:data) {
      {
        rows: [
          { 'Subject' => 'English', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 0 },
          { 'Subject' => 'Geography and History', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 1, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 1 },
          { 'Subject' => 'Mathematics', 'Recruited' => 0, 'Conditions pending' => 1, 'Received an offer' => 0, 'Awaiting provider decisions' => 1, 'Unsuccessful' => 1, 'Total' => 3 },
          { 'Subject' => 'Modern languages', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 0 },
          { 'Subject' => 'Physical Education', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 1, 'Total' => 1 },
          { 'Subject' => 'Science', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 1, 'Total' => 1 },
          { 'Subject' => 'No specialist subject', 'Recruited' => 1, 'Conditions pending' => 0, 'Received an offer' => 2, 'Awaiting provider decisions' => 1, 'Unsuccessful' => 1, 'Total' => 5 },
        ],
        column_totals: [1, 1, 3, 2, 4, 11],
      }
    }

    before do
      monthly_statistics_double = instance_double(MonthlyStatistics::ByPrimarySpecialistSubject)
      allow(MonthlyStatistics::ByPrimarySpecialistSubject).to receive(:new).and_return monthly_statistics_double
      allow(monthly_statistics_double).to receive(:table_data).and_return data
    end

    it 'returns data for export in the desired state' do
      data_to_ouput = described_class.new.data_for_export

      expect(data_to_ouput).to eq(
        [
          { 'Subject' => 'English', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 0 },
          { 'Subject' => 'Geography and History', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 1, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 1 },
          { 'Subject' => 'Mathematics', 'Recruited' => 0, 'Conditions pending' => 1, 'Received an offer' => 0, 'Awaiting provider decisions' => 1, 'Unsuccessful' => 1, 'Total' => 3 },
          { 'Subject' => 'Modern languages', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 0 },
          { 'Subject' => 'Physical Education', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 1, 'Total' => 1 },
          { 'Subject' => 'Science', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 1, 'Total' => 1 },
          { 'Subject' => 'No specialist subject', 'Recruited' => 1, 'Conditions pending' => 0, 'Received an offer' => 2, 'Awaiting provider decisions' => 1, 'Unsuccessful' => 1, 'Total' => 5 },
          { 'Subject' => 'Total', 'Recruited' => 1, 'Conditions pending' => 1, 'Received an offer' => 3, 'Awaiting provider decisions' => 2, 'Unsuccessful' => 4, 'Total' => 11 },
        ],
      )
    end
  end
end
