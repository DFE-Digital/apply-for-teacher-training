require 'rails_helper'

RSpec.describe Publications::MonthlyStatistics::ByArea do
  include MonthlyStatisticsTestHelper

  before { generate_monthly_statistics_test_data }

  let(:statistics) { described_class.new.table_data }

  it "returns table data for 'by area'" do
    expect_report_rows(column_headings: ['Area', 'Recruited', 'Conditions pending', 'Deferrals', 'Received an offer', 'Awaiting provider decisions', 'Unsuccessful', 'Total']) do
      [['Channel Islands',          0, 0, 0, 0, 0, 0, 0],
       ['East Midlands',            0, 0, 0, 0, 1, 0, 1],
       ['Eastern',                  1, 0, 0, 0, 0, 0, 1],
       ['Isle of Man',              0, 0, 0, 0, 0, 0, 0],
       ['London',                   0, 0, 1, 0, 0, 0, 1],
       ['No region',                0, 0, 0, 0, 0, 1, 1],
       ['North East',               1, 0, 0, 0, 0, 0, 1],
       ['North West',               0, 1, 0, 0, 0, 0, 1],
       ['Northern Ireland',         0, 0, 0, 0, 0, 0, 0],
       ['Scotland',                 0, 0, 0, 0, 0, 0, 0],
       ['South East',               0, 0, 0, 0, 0, 0, 0],
       ['South West',               0, 0, 0, 0, 0, 0, 0],
       ['Wales',                    0, 0, 0, 0, 0, 0, 0],
       ['West Midlands',            0, 0, 0, 0, 0, 1, 1],
       ['Yorkshire and the Humber', 0, 0, 0, 1, 0, 0, 1],
       ['European Economic Area',   0, 0, 0, 0, 0, 0, 0],
       ['Rest of the World',        0, 0, 0, 0, 0, 0, 0]]
    end

    expect_column_totals(2, 1, 1, 1, 1, 2, 8)
  end
end
