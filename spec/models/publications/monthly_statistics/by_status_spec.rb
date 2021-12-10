require 'rails_helper'

RSpec.describe Publications::MonthlyStatistics::ByStatus do
  include MonthlyStatisticsTestHelper

  before { generate_monthly_statistics_test_data }

  context 'applications by status table data' do
    subject(:statistics) { described_class.new.table_data }

    it "returns table data for 'applications by status'" do
      expect_report_rows(column_headings: ['Status', 'First application', 'Apply again', 'Total']) do
        [['Recruited', 1, 1, 2],
         ['Conditions pending', 1, 0, 1],
         ['Deferred', 1, 0, 1],
         ['Received an offer but not responded', 1, 0, 1],
         ['Awaiting provider decisions', 1, 0, 1],
         ['Declined an offer', 1, 0, 1],
         ['Withdrew an application', 1, 0, 1],
         ['Application rejected', 1, 0, 1]]
      end

      expect_column_totals(8, 1, 9)
    end
  end

  context 'candidates by status table data' do
    subject(:statistics) { described_class.new(by_candidate: true).table_data }

    it "returns table data for 'candidates by status'" do
      expect_report_rows(column_headings: ['Status', 'First application', 'Apply again', 'Total']) do
        [['Recruited', 1, 1, 2],
         ['Conditions pending', 1, 0, 1],
         ['Deferred', 1, 0, 1],
         ['Received an offer but not responded', 1, 0, 1],
         ['Awaiting provider decisions', 1, 0, 1],
         ['Declined an offer', 1, 0, 1],
         ['Withdrew an application', 1, 0, 1],
         ['Application rejected', 0, 0, 0]]
      end

      expect_column_totals(7, 1, 8)
    end
  end
end
