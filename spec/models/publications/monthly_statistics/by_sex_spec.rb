require 'rails_helper'

RSpec.describe Publications::MonthlyStatistics::BySex do
  include StatisticsTestHelper

  before { generate_statistics_test_data }

  subject(:statistics) { described_class.new.table_data }

  it "returns table data for 'by course age group'" do
    expect_report_rows(column_headings: ['Sex', 'Recruited', 'Conditions pending', 'Deferred', 'Received an offer', 'Awaiting provider decisions', 'Unsuccessful', 'Total']) do
      [['Female',            2, 1, 1, 1, 0, 1, 6],
       ['Male',              1, 0, 0, 0, 0, 0, 1],
       ['Intersex',          0, 0, 0, 0, 0, 1, 1],
       ['Prefer not to say', 0, 0, 0, 0, 1, 0, 1]]
    end

    expect_column_totals(3, 1, 1, 1, 1, 2, 9)
  end
end
