require 'rails_helper'

RSpec.describe Publications::MonthlyStatistics::ByPrimarySpecialistSubject do
  include MonthlyStatisticsTestHelper

  before { generate_monthly_statistics_test_data }

  subject(:statistics) { described_class.new.table_data }

  it 'generates correct table data' do
    expect_report_rows(column_headings: ['Subject', 'Recruited', 'Conditions pending', 'Received an offer', 'Awaiting provider decisions', 'Unsuccessful', 'Total']) do
      [['Primary', 0, 0, 0, 1, 0, 1],
       ['Primary with English', 0, 1, 0, 0, 0, 1],
       ['Primary with geography and history', 0, 0, 1, 0, 0, 1],
       ['Primary with mathematics', 1, 0, 0, 0, 0, 1]]
    end

    expect_column_totals(1, 1, 1, 1, 0, 4)
  end
end
