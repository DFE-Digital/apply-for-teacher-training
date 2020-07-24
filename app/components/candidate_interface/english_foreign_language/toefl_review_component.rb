module CandidateInterface
  module EnglishForeignLanguage
    class ToeflReviewComponent < ViewComponent::Base
      include EflReviewHelper

      attr_reader :toefl_qualification

      def initialize(toefl_qualification)
        @toefl_qualification = toefl_qualification
      end

      def toefl_rows
        [
          do_you_have_a_qualification_row(value: 'Yes'),
          type_of_qualification_row(name: 'TOEFL'),
          {
            key: 'TOEFL registration number',
            value: toefl_qualification.registration_number,
            action: 'Change registration number',
            change_path: candidate_interface_edit_toefl_path,
          },
          {
            key: 'Year awarded',
            value: toefl_qualification.award_year,
            action: 'Change year awarded',
            change_path: candidate_interface_edit_toefl_path,
          },
          {
            key: 'Total score',
            value: toefl_qualification.total_score,
            action: 'Change total score',
            change_path: candidate_interface_edit_toefl_path,
          },
        ]
      end
    end
  end
end
