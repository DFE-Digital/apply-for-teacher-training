module CandidateInterface
  module EnglishForeignLanguage
    class IeltsReviewComponent < ApplicationComponent
      include EflReviewHelper

      attr_reader :ielts_qualification, :return_to_application_review, :editable

      def initialize(ielts_qualification, return_to_application_review: false, editable: true)
        @ielts_qualification = ielts_qualification
        @return_to_application_review = return_to_application_review
        @editable = editable
      end

      def ielts_rows
        [
          do_you_have_a_qualification_row(value: 'Yes', return_to_application_review:, editable:),
          type_of_qualification_row(name: 'IELTS', return_to_application_review:, editable:),
          trf_number_row,
          band_score_row,
          year_completed_row,
        ]
      end

    private

      def trf_number_row
        {
          key: 'Test report form (TRF) number',
          value: ielts_qualification.trf_number,
        }.tap do |row|
          if editable
            row[:action] = {
              href: candidate_interface_edit_ielts_path(return_to_params(return_to_application_review)),
              visually_hidden_text: 'TRF number',
            }
          end
        end
      end

      def band_score_row
        {
          key: 'Overall band score',
          value: ielts_qualification.band_score,
        }.tap do |row|
          if editable
            row[:action] = {
              href: candidate_interface_edit_ielts_path(return_to_params(return_to_application_review)),
              visually_hidden_text: 'overall band score',
            }
          end
        end
      end

      def year_completed_row
        {
          key: 'Year completed',
          value: ielts_qualification.award_year,
        }.tap do |row|
          if editable
            row[:action] = {
              href: candidate_interface_edit_ielts_path(return_to_params(return_to_application_review)),
              visually_hidden_text: 'year completed',
            }
          end
        end
      end
    end
  end
end
