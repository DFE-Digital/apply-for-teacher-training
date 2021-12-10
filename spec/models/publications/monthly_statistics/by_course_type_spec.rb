require 'rails_helper'

RSpec.describe Publications::MonthlyStatistics::ByCourseType do
  include MonthlyStatisticsTestHelper

  before { generate_monthly_statistics_test_data }

  subject(:statistics) { described_class.new.table_data }

  it "returns table data for 'by course type'" do
    expect_report_rows(column_headings: ['Course type', 'Recruited', 'Conditions pending', 'Deferred', 'Received an offer', 'Awaiting provider decisions', 'Unsuccessful', 'Total']) do
      [['Higher education', 1, 0, 1, 0, 0, 3, 5],
       ['Postgraduate teaching apprenticeship', 0, 0, 0, 1, 0, 0, 1],
       ['School-centred initial teacher training (SCITT)', 0, 0, 0, 0, 1, 0, 1],
       ['School Direct (fee-paying)', 1, 0, 0, 0, 0, 0, 1],
       ['School Direct (salaried)', 0, 1, 0, 0, 0, 0, 1]]
    end

    expect_column_totals(2, 1, 1, 1, 1, 3, 9)
  end
end
