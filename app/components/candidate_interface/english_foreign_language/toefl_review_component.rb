module CandidateInterface
  module EnglishForeignLanguage
    class ToeflReviewComponent < ApplicationComponent
      include EflReviewHelper

      attr_reader :toefl_qualification, :return_to_application_review

      def initialize(toefl_qualification, return_to_application_review: false)
        @toefl_qualification = toefl_qualification
        @return_to_application_review = return_to_application_review
      end

      def toefl_rows
        [
          do_you_have_a_qualification_row(value: 'Yes', return_to_application_review:),
          type_of_qualification_row(name: 'TOEFL', return_to_application_review:),
          {
            key: 'TOEFL registration number',
            value: toefl_qualification.registration_number,
            action: {
              href: candidate_interface_edit_toefl_path(return_to_params(return_to_application_review)),
              visually_hidden_text: 'registration number',
            },
            html: {
              data: {
                qa: 'english-as-a-foreign-language-registration-number',
              },
            },
          },
          {
            key: 'Year completed',
            value: toefl_qualification.award_year,
            action: {
              href: candidate_interface_edit_toefl_path(return_to_params(return_to_application_review)),
              visually_hidden_text: 'year completed',
            },
            html_attributes: {
              data: {
                qa: 'english-as-a-foreign-language-year-completed',
              },
            },
          },
          {
            key: 'Total score',
            value: toefl_qualification.total_score,
            action: {
              href: candidate_interface_edit_toefl_path(return_to_params(return_to_application_review)),
              visually_hidden_text: 'total score',
            },
            html_attributes: {
              data: {
                qa: 'english-as-a-foreign-language-total-score',
              },
            },
          },
        ]
      end
    end
  end
end
