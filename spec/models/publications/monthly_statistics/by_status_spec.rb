require 'rails_helper'

RSpec.describe Publications::MonthlyStatistics::ByStatus do
  include StatisticsTestHelper

  before { generate_statistics_test_data }

  context 'applications by status table data' do
    subject(:statistics) { described_class.new.table_data }

    it "returns table data for 'applications by status'" do
      expect_report_rows(column_headings: ['Status', 'First application', 'Apply again', 'Total']) do
        [['Recruited',                           3, 1, 4],
         ['Conditions pending',                  1, 0, 1],
         ['Deferred',                            1, 0, 1],
         ['Received an offer but not responded', 1, 0, 1],
         ['Awaiting provider decisions',         4, 0, 4],
         ['Declined an offer',                   1, 0, 1],
         ['Withdrew an application',             3, 1, 4],
         ['Application rejected',                7, 1, 8]]
      end

      expect_column_totals(21, 3, 24)
    end
  end

  context 'candidates by status table data' do
    subject(:statistics) { described_class.new(by_candidate: true).table_data }

    it "returns table data for 'candidates by status'" do
      expect_report_rows(column_headings: ['Status', 'First application', 'Apply again', 'Total']) do
        [['Recruited',                           3, 1, 4],
         ['Conditions pending',                  1, 0, 1],
         ['Deferred',                            1, 0, 1],
         ['Received an offer but not responded', 1, 0, 1],
         ['Awaiting provider decisions',         1, 0, 1],
         ['Declined an offer',                   1, 0, 1],
         ['Withdrew an application',             1, 1, 2],
         ['Application rejected',                3, 1, 4]]
      end

      expect_column_totals(12, 3, 15)
    end
  end
end
