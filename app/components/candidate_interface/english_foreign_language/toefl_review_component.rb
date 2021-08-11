module CandidateInterface
  module EnglishForeignLanguage
    class ToeflReviewComponent < ViewComponent::Base
      include EflReviewHelper

      attr_reader :toefl_qualification, :return_to_application_review

      def initialize(toefl_qualification, return_to_application_review: false)
        @toefl_qualification = toefl_qualification
        @return_to_application_review = return_to_application_review
      end

      def toefl_rows
        [
          do_you_have_a_qualification_row(value: 'Yes', return_to_application_review: return_to_application_review),
          type_of_qualification_row(name: 'TOEFL', return_to_application_review: return_to_application_review),
          {
            key: 'TOEFL registration number',
            value: toefl_qualification.registration_number,
            action: 'registration number',
            change_path: candidate_interface_edit_toefl_path(return_to_params(return_to_application_review)),
            data_qa: 'english-as-a-foreign-language-registration-number',
          },
          {
            key: 'Year completed',
            value: toefl_qualification.award_year,
            action: 'year completed',
            change_path: candidate_interface_edit_toefl_path(return_to_params(return_to_application_review)),
            data_qa: 'english-as-a-foreign-language-year-completed',
          },
          {
            key: 'Total score',
            value: toefl_qualification.total_score,
            action: 'total score',
            change_path: candidate_interface_edit_toefl_path(return_to_params(return_to_application_review)),
            data_qa: 'english-as-a-foreign-language-total-score',
          },
        ]
      end
    end
  end
end
