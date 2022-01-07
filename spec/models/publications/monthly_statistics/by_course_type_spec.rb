require 'rails_helper'

RSpec.describe Publications::MonthlyStatistics::ByCourseType do
  include StatisticsTestHelper

  before { generate_statistics_test_data }

  subject(:statistics) { described_class.new.table_data }

  it "returns table data for 'by course type'" do
    expect_report_rows(column_headings: ['Course type', 'Recruited', 'Conditions pending', 'Deferred', 'Received an offer', 'Awaiting provider decisions', 'Unsuccessful', 'Total']) do
      [['Higher education',                                2, 0, 1, 0, 0, 3, 6],
       ['Postgraduate teaching apprenticeship',            0, 0, 0, 1, 1, 0, 2],
       ['School-centred initial teacher training (SCITT)', 0, 0, 0, 0, 3, 0, 3],
       ['School Direct (fee-paying)',                      1, 0, 0, 0, 0, 0, 1],
       ['School Direct (salaried)',                        0, 1, 0, 0, 0, 0, 1]]
    end

    expect_column_totals(3, 1, 1, 1, 4, 3, 13)
  end
end
