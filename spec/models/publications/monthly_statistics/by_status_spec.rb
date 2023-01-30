require 'rails_helper'

RSpec.describe Publications::MonthlyStatistics::ByStatus do
  include StatisticsTestHelper

  before { generate_statistics_test_data }

  context 'applications by status table data' do
    subject(:statistics) { described_class.new.table_data }

    it "returns table data for 'applications by status'" do
      expect_report_rows(column_headings: ['Status', 'First application', 'Apply again', 'Total']) do
        [['Recruited',                           3, 1, 4],
         ['Conditions pending',                  2, 0, 2],
         ['Deferred',                            1, 0, 1],
         ['Received an offer but not responded', 1, 0, 1],
         ['Awaiting provider decisions',         4, 0, 4],
         ['Declined an offer',                   1, 0, 1],
         ['Withdrew an application',             5, 1, 6],
         ['Application rejected',                5, 3, 8]]
      end

      expect_column_totals(22, 5, 27)
    end
  end

  context 'candidates by status table data' do
    subject(:statistics) { described_class.new(by_candidate: true).table_data }

    it "returns table data for 'candidates by status'" do
      expect_report_rows(column_headings: ['Status', 'First application', 'Apply again', 'Total']) do
        [['Recruited',                           3, 1, 4],
         ['Conditions pending',                  2, 0, 2],
         ['Deferred',                            1, 0, 1],
         ['Received an offer but not responded', 1, 0, 1],
         ['Awaiting provider decisions',         1, 0, 1],
         ['Declined an offer',                   0, 0, 0],
         ['Withdrew an application',             2, 1, 3],
         ['Application rejected',                2, 2, 4]]
      end

      expect_column_totals(12, 4, 16)
    end
  end
end
