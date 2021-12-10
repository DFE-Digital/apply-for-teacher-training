require 'rails_helper'

RSpec.describe Publications::MonthlyStatistics::ByCourseAgeGroup do
  include MonthlyStatisticsTestHelper

  before { generate_monthly_statistics_test_data }

  subject(:statistics) { described_class.new.table_data }

  it "returns table data for 'by course age group'" do
    expect_report_rows(column_headings: ['Age group', 'Recruited', 'Conditions pending', 'Deferred', 'Received an offer', 'Awaiting provider decisions', 'Unsuccessful', 'Total']) do
      [['Primary', 1, 1, 0, 1, 1, 0, 4],
       ['Secondary', 1, 0, 1, 0, 0, 2, 4],
       ['Further education', 0, 0, 0, 0, 0, 1, 1]]
    end

    expect_column_totals(2, 1, 1, 1, 1, 3, 9)
  end
end
