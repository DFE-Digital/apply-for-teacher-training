module CandidateInterface
  module EnglishForeignLanguage
    class OtherEflQualificationReviewComponent < ApplicationComponent
      include EflReviewHelper

      attr_reader :other_qualification, :return_to_application_review

      def initialize(other_qualification, return_to_application_review: false)
        @other_qualification = other_qualification
        @return_to_application_review = return_to_application_review
      end

      def ielts_rows
        [
          do_you_have_a_qualification_row(value: 'Yes', return_to_application_review:),
          type_of_qualification_row(name: other_qualification.name, return_to_application_review:),
          {
            key: 'Score or grade',
            value: other_qualification.grade,
            action: {
              href: candidate_interface_edit_other_efl_qualification_path(return_to_params(return_to_application_review)),
              visually_hidden_text: 'score or grade',
            },
          },
          {
            key: 'Year completed',
            value: other_qualification.award_year,
            action: {
              href: candidate_interface_edit_other_efl_qualification_path(return_to_params(return_to_application_review)),
              visually_hidden_text: 'year completed',
            },
          },
        ]
      end
    end
  end
end
