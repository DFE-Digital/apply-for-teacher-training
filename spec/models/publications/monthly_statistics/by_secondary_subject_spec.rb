require 'rails_helper'

RSpec.describe Publications::MonthlyStatistics::BySecondarySubject do
  include MonthlyStatisticsTestHelper

  before { generate_monthly_statistics_test_data }

  subject(:statistics) { described_class.new.table_data }

  it 'correctly generates table data' do
    expect_report_rows(column_headings: ['Subject', 'Recruited', 'Conditions pending', 'Deferred', 'Received an offer', 'Awaiting provider decisions', 'Unsuccessful', 'Total']) do
      [['Art and design', 0, 0, 0, 0, 0, 1, 1],
       ['Subject not recognised', 1, 0, 1, 0, 0, 1, 3]]
    end

    expect_column_totals(1, 0, 1, 0, 0, 2, 4)
  end
end
