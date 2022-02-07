require 'rails_helper'

RSpec.describe Publications::MonthlyStatistics::ByAgeGroup do
  include StatisticsTestHelper

  before { generate_statistics_test_data }

  let(:statistics) do
    described_class.new.table_data
  end

  it "returns rows for 'by age group'" do
    expect_report_rows(column_headings: ['Age group', 'Recruited', 'Conditions pending', 'Deferrals', 'Received an offer', 'Awaiting provider decisions', 'Unsuccessful', 'Total']) do
      [['21 and under', 1, 0, 0, 0, 0, 0, 1],
       ['22',           0, 0, 0, 0, 0, 0, 0],
       ['23',           0, 1, 0, 0, 0, 0, 1],
       ['24',           0, 0, 0, 1, 0, 0, 1],
       ['25 to 29',     0, 0, 0, 0, 1, 2, 3],
       ['30 to 34',     0, 0, 0, 0, 0, 1, 1],
       ['35 to 39',     0, 0, 0, 0, 0, 1, 1],
       ['40 to 44',     2, 0, 0, 0, 0, 0, 2],
       ['45 to 49',     0, 0, 0, 0, 0, 0, 0],
       ['50 to 54',     0, 0, 0, 0, 0, 0, 0],
       ['55 to 59',     0, 0, 0, 0, 0, 0, 0],
       ['60 to 64',     0, 0, 0, 0, 0, 0, 0],
       ['65 and over',  1, 0, 1, 0, 0, 1, 3]]
    end

    expect_column_totals(4, 1, 1, 1, 1, 5, 13)
  end
end
