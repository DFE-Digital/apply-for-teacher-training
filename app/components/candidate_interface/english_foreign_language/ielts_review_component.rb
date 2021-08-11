module CandidateInterface
  module EnglishForeignLanguage
    class IeltsReviewComponent < ViewComponent::Base
      include EflReviewHelper

      attr_reader :ielts_qualification, :return_to_application_review

      def initialize(ielts_qualification, return_to_application_review: false)
        @ielts_qualification = ielts_qualification
        @return_to_application_review = return_to_application_review
      end

      def ielts_rows
        [
          do_you_have_a_qualification_row(value: 'Yes', return_to_application_review: return_to_application_review),
          type_of_qualification_row(name: 'IELTS', return_to_application_review: return_to_application_review),
          {
            key: 'Test report form (TRF) number',
            value: ielts_qualification.trf_number,
            action: 'Change TRF number',
            change_path: candidate_interface_edit_ielts_path,
          },
          {
            key: 'Year completed',
            value: ielts_qualification.award_year,
            action: 'Change year completed',
            change_path: candidate_interface_edit_ielts_path,
          },
          {
            key: 'Overall band score',
            value: ielts_qualification.band_score,
            action: 'Change overall band score',
            change_path: candidate_interface_edit_ielts_path,
          },
        ]
      end
    end
  end
end
