require 'rails_helper'

RSpec.describe Publications::MonthlyStatistics::ByProviderArea do
  include StatisticsTestHelper

  before { generate_statistics_test_data }

  subject(:statistics) { described_class.new.table_data }

  it "returns table data for 'applications by provider area'" do
    expect_report_rows(column_headings: ['Area', 'Recruited', 'Conditions pending', 'Deferred', 'Received an offer', 'Awaiting provider decisions', 'Unsuccessful', 'Total']) do
      [['East of England',          1, 0, 0, 0, 0, 0, 1],
       ['East Midlands',            0, 1, 0, 0, 0, 1, 2],
       ['London',                   0, 0, 0, 1, 0, 0, 1],
       ['North East',               0, 0, 0, 0, 1, 0, 1],
       ['North West',               0, 0, 0, 0, 1, 1, 2],
       ['South East',               0, 0, 0, 0, 1, 1, 2],
       ['South West',               0, 0, 0, 0, 0, 1, 1],
       ['West Midlands',            2, 0, 1, 0, 0, 3, 6],
       ['Yorkshire and The Humber', 1, 0, 0, 0, 1, 2, 4]]
    end

    expect_column_totals(4, 1, 1, 1, 4, 9, 20)
  end
end
