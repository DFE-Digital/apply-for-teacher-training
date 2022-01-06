require 'rails_helper'

RSpec.describe SupportInterface::MinisterialReportApplicationsExport do
  include MonthlyStatisticsTestHelper

  describe '#call' do
    let(:statistics) do
      generate_monthly_statistics_test_data

      { rows: described_class.new.call }
    end

    it 'returns the correct data' do
      expect_report_rows(column_headings: %i[
        subject
        applications
        offer_received
        accepted
        application_declined
        application_rejected
        application_withdrawn
      ]) do
        [[:art_and_design,           1, 0, 0, 1, 0, 0],
         [:biology,                  0, 0, 0, 0, 0, 0],
         [:business_studies,         0, 0, 0, 0, 0, 0],
         [:chemistry,                0, 0, 0, 0, 0, 0],
         [:classics,                 0, 0, 0, 0, 0, 0],
         [:computing,                0, 0, 0, 0, 0, 0],
         [:design_and_technology,    0, 0, 0, 0, 0, 0],
         [:drama,                    0, 0, 0, 0, 0, 0],
         [:english,                  1, 0, 0, 0, 0, 1],
         [:geography,                1, 1, 1, 0, 0, 0],
         [:history,                  0, 0, 0, 0, 0, 0],
         [:mathematics,              0, 0, 0, 0, 0, 0],
         [:modern_foreign_languages, 1, 1, 1, 0, 0, 0],
         [:music,                    0, 0, 0, 0, 0, 0],
         [:other,                    1, 1, 1, 0, 0, 0],
         [:physical_education,       0, 0, 0, 0, 0, 0],
         [:physics,                  0, 0, 0, 0, 0, 0],
         [:religious_education,      0, 0, 0, 0, 0, 0],
         [:stem,                     0, 0, 0, 0, 0, 0],
         [:ebacc,                    3, 2, 2, 0, 0, 1],
         [:primary,                  7, 3, 2, 0, 0, 0],
         [:secondary,                6, 3, 3, 1, 1, 1],
         [:total,                    13, 6, 5, 1, 1, 1]]
      end
    end
  end
end
