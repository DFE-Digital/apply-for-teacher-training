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
         [:biology,                  3, 1, 1, 0, 1, 1],
         [:business_studies,         2, 2, 2, 0, 0, 0],
         [:chemistry,                1, 0, 0, 0, 1, 0],
         [:classics,                 0, 0, 0, 0, 0, 0],
         [:computing,                0, 0, 0, 0, 0, 0],
         [:design_and_technology,    0, 0, 0, 0, 0, 0],
         [:drama,                    2, 0, 0, 0, 2, 0],
         [:english,                  1, 0, 0, 0, 0, 1],
         [:further_education,        1, 0, 0, 0, 1, 0],
         [:geography,                0, 0, 0, 0, 0, 0],
         [:history,                  1, 0, 0, 0, 0, 1],
         [:mathematics,              2, 0, 0, 0, 2, 0],
         [:modern_foreign_languages, 3, 1, 1, 0, 1, 1],
         [:music,                    0, 0, 0, 0, 0, 0],
         [:other,                    2, 1, 1, 0, 0, 1],
         [:physical_education,       0, 0, 0, 0, 0, 0],
         [:physics,                  1, 0, 0, 0, 0, 1],
         [:religious_education,      0, 0, 0, 0, 0, 0],
         [:stem,                     7, 1, 1, 0, 4, 2],
         [:ebacc,                    12, 2, 2, 0, 5, 5],
         [:primary,                  7, 3, 2, 0, 0, 0],
         [:secondary,                19, 6, 5, 1, 7, 6],
         [:total,                    26, 9, 7, 1, 7, 6]]
      end
    end
  end
end
