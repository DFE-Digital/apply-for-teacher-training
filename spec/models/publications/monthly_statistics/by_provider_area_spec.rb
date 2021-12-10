require 'rails_helper'

RSpec.describe Publications::MonthlyStatistics::ByProviderArea do
  include MonthlyStatisticsTestHelper

  before { generate_monthly_statistics_test_data }
  subject(:statistics) { described_class.new.table_data }

  it "returns table data for 'applications by provider area'" do
    expect_report_rows(column_headings: ['Area', 'Recruited', 'Conditions pending', 'Received an offer', 'Awaiting provider decisions', 'Unsuccessful', 'Total']) do
      [['East', 1, 0, 0, 0, 0, 1],
       ['East Midlands', 0, 1, 0, 0, 0, 1],
       ['London', 0, 0, 1, 0, 0, 1],
       ['North East', 0, 0, 0, 1, 0, 1],
       ['North West', 0, 0, 0, 0, 1, 1],
       ['South East', 0, 0, 0, 0, 1, 1],
       ['South West', 0, 0, 0, 0, 1, 1],
       ['West Midlands', 0, 0, 0, 0, 0, 0],
       ['Yorkshire and The Humber', 1, 0, 0, 0, 0, 1]]
    end

    expect_column_totals(2, 1, 1, 1, 3, 8)
  end
end
