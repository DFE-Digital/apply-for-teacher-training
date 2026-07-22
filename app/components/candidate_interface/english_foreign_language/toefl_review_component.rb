module CandidateInterface
  module EnglishForeignLanguage
    class ToeflReviewComponent < ApplicationComponent
      include EflReviewHelper

      attr_reader :toefl_qualification, :return_to_application_review, :editable

      def initialize(toefl_qualification, return_to_application_review: false, editable: true)
        @toefl_qualification = toefl_qualification
        @return_to_application_review = return_to_application_review
        @editable = editable
      end

      def toefl_rows
        [
          do_you_have_a_qualification_row(value: 'Yes', return_to_application_review:, editable:),
          type_of_qualification_row(name: 'TOEFL', return_to_application_review:, editable:),
          registration_number_row,
          year_completed_row,
          total_score_row,
        ]
      end

    private

      def registration_number_row
        {
          key: 'TOEFL registration number',
          value: toefl_qualification.registration_number,
          html: {
            data: {
              qa: 'english-as-a-foreign-language-registration-number',
            },
          },
        }.tap do |row|
          if editable
            row[:action] = {
              href: candidate_interface_edit_toefl_path(return_to_params(return_to_application_review)),
              visually_hidden_text: 'registration number',
            }
          end
        end
      end

      def year_completed_row
        {
          key: 'Year completed',
          value: toefl_qualification.award_year,
          html_attributes: {
            data: {
              qa: 'english-as-a-foreign-language-year-completed',
            },
          },
        }.tap do |row|
          if editable
            row[:action] = {
              href: candidate_interface_edit_toefl_path(return_to_params(return_to_application_review)),
              visually_hidden_text: 'year completed',
            }
          end
        end
      end

      def total_score_row
        {
          key: 'Total score',
          value: toefl_qualification.total_score,
          html_attributes: {
            data: {
              qa: 'english-as-a-foreign-language-total-score',
            },
          },
        }.tap do |row|
          if editable
            row[:action] = {
              href: candidate_interface_edit_toefl_path(return_to_params(return_to_application_review)),
              visually_hidden_text: 'total score',
            }
          end
        end
      end
    end
  end
end
