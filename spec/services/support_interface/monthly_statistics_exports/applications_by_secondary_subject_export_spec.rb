require 'rails_helper'

RSpec.describe SupportInterface::MonthlyStatisticsExports::ApplicationsBySecondarySubjectExport do
  describe '#data_for_export' do
    let(:data) {
      {
        rows: [
          { 'Subject' => 'Art and design', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 1, 'Total' => 1 },
          { 'Subject' => 'Science', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 0 },
          { 'Subject' => 'Biology', 'Recruited' => 0, 'Conditions pending' => 1, 'Received an offer' => 0, 'Awaiting provider decisions' => 1, 'Unsuccessful' => 0, 'Total' => 2 },
          { 'Subject' => 'Business studies', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 0 },
          { 'Subject' => 'Chemistry', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 1, 'Total' => 1 },
          { 'Subject' => 'Citizenship', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 0 },
          { 'Subject' => 'Classics', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 0 },
          { 'Subject' => 'Communication and media studies', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 0 },
          { 'Subject' => 'Computing', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 1, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 1 },
          { 'Subject' => 'Dance', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 0 },
          { 'Subject' => 'Design and technology', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 1, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 1 },
          { 'Subject' => 'Drama', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 5, 'Unsuccessful' => 0, 'Total' => 5 },
          { 'Subject' => 'Economics', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 0 },
          { 'Subject' => 'English', 'Recruited' => 1, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 1, 'Unsuccessful' => 0, 'Total' => 2 },
          { 'Subject' => 'Geography', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 0 },
          { 'Subject' => 'Health and social care', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 0 },
          { 'Subject' => 'History', 'Recruited' => 1, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 1, 'Total' => 2 },
          { 'Subject' => 'Mathematics', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 1, 'Total' => 1 },
          { 'Subject' => 'Modern foreign languages', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 1, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 1 },
          { 'Subject' => 'Music', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 1, 'Unsuccessful' => 0, 'Total' => 1 },
          { 'Subject' => 'Philosophy', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 0 },
          { 'Subject' => 'Physical education', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 2, 'Unsuccessful' => 0, 'Total' => 2 },
          { 'Subject' => 'Physics', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 1, 'Awaiting provider decisions' => 1, 'Unsuccessful' => 1, 'Total' => 3 },
          { 'Subject' => 'Psychology', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 0 },
          { 'Subject' => 'Religious education', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 2, 'Unsuccessful' => 1, 'Total' => 3 },
          { 'Subject' => 'Social sciences', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 0 },
          { 'Subject' => 'Further education', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 0 },
        ],
        column_totals: [2, 1, 4, 13, 6, 26],
      }
    }

    before do
      monthly_statistics_double = instance_double(Publications::MonthlyStatistics::BySecondarySubject)
      allow(Publications::MonthlyStatistics::BySecondarySubject).to receive(:new).and_return monthly_statistics_double
      allow(monthly_statistics_double).to receive(:table_data).and_return data
    end

    it 'returns data for export in the desired state' do
      data_to_ouput = described_class.new.data_for_export

      expect(data_to_ouput).to eq(
        [
          { 'Subject' => 'Art and design', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 1, 'Total' => 1 },
          { 'Subject' => 'Science', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 0 },
          { 'Subject' => 'Biology', 'Recruited' => 0, 'Conditions pending' => 1, 'Received an offer' => 0, 'Awaiting provider decisions' => 1, 'Unsuccessful' => 0, 'Total' => 2 },
          { 'Subject' => 'Business studies', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 0 },
          { 'Subject' => 'Chemistry', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 1, 'Total' => 1 },
          { 'Subject' => 'Citizenship', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 0 },
          { 'Subject' => 'Classics', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 0 },
          { 'Subject' => 'Communication and media studies', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 0 },
          { 'Subject' => 'Computing', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 1, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 1 },
          { 'Subject' => 'Dance', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 0 },
          { 'Subject' => 'Design and technology', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 1, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 1 },
          { 'Subject' => 'Drama', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 5, 'Unsuccessful' => 0, 'Total' => 5 },
          { 'Subject' => 'Economics', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 0 },
          { 'Subject' => 'English', 'Recruited' => 1, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 1, 'Unsuccessful' => 0, 'Total' => 2 },
          { 'Subject' => 'Geography', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 0 },
          { 'Subject' => 'Health and social care', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 0 },
          { 'Subject' => 'History', 'Recruited' => 1, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 1, 'Total' => 2 },
          { 'Subject' => 'Mathematics', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 1, 'Total' => 1 },
          { 'Subject' => 'Modern foreign languages', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 1, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 1 },
          { 'Subject' => 'Music', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 1, 'Unsuccessful' => 0, 'Total' => 1 },
          { 'Subject' => 'Philosophy', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 0 },
          { 'Subject' => 'Physical education', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 2, 'Unsuccessful' => 0, 'Total' => 2 },
          { 'Subject' => 'Physics', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 1, 'Awaiting provider decisions' => 1, 'Unsuccessful' => 1, 'Total' => 3 },
          { 'Subject' => 'Psychology', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 0 },
          { 'Subject' => 'Religious education', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 2, 'Unsuccessful' => 1, 'Total' => 3 },
          { 'Subject' => 'Social sciences', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 0 },
          { 'Subject' => 'Further education', 'Recruited' => 0, 'Conditions pending' => 0, 'Received an offer' => 0, 'Awaiting provider decisions' => 0, 'Unsuccessful' => 0, 'Total' => 0 },
          { 'Subject' => 'Total', 'Recruited' => 2, 'Conditions pending' => 1, 'Received an offer' => 4, 'Awaiting provider decisions' => 13, 'Unsuccessful' => 6, 'Total' => 26 },
        ],
      )
    end
  end
end
