require 'rails_helper'

RSpec.describe SupportInterface::MinisterialReportApplicationsExport do
  include StatisticsTestHelper

  describe '#call' do
    let(:statistics) do
      generate_statistics_test_data

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
        [[:art_and_design,           1, 1, 0, 1, 0, 0],
         [:biology,                  0, 0, 0, 0, 0, 0],
         [:business_studies,         0, 0, 0, 0, 0, 0],
         [:chemistry,                1, 0, 0, 0, 1, 0],
         [:classics,                 0, 0, 0, 0, 0, 0],
         [:computing,                0, 0, 0, 0, 0, 0],
         [:design_and_technology,    0, 0, 0, 0, 0, 0],
         [:drama,                    0, 0, 0, 0, 0, 0],
         [:english,                  1, 0, 0, 0, 0, 1],
         [:further_education,        1, 0, 0, 0, 1, 0],
         [:geography,                1, 1, 1, 0, 0, 0],
         [:history,                  0, 0, 0, 0, 0, 0],
         [:mathematics,              2, 0, 0, 0, 2, 0],
         [:modern_foreign_languages, 1, 1, 1, 0, 0, 0],
         [:music,                    0, 0, 0, 0, 0, 0],
         [:other,                    2, 1, 1, 0, 0, 0],
         [:physical_education,       0, 0, 0, 0, 0, 0],
         [:physics,                  1, 0, 0, 0, 0, 1],
         [:religious_education,      0, 0, 0, 0, 0, 0],
         [:stem,                     4, 0, 0, 0, 3, 1],
         [:ebacc,                    7, 2, 2, 0, 3, 2],
         [:primary,                  7, 3, 2, 0, 0, 0],
         [:secondary,                10, 4, 3, 1, 3, 2],
         [:total,                    17, 7, 5, 1, 3, 2]]
      end
    end
  end
end
