module CandidateInterface
  module EnglishForeignLanguage
    class IeltsReviewComponent < ViewComponent::Base
      include EflReviewHelper

      attr_reader :ielts_qualification

      def initialize(ielts_qualification)
        @ielts_qualification = ielts_qualification
      end

      def ielts_rows
        [
          do_you_have_a_qualification_row(value: 'Yes'),
          type_of_qualification_row(name: 'IELTS'),
          {
            key: 'Test report form (TRF) number',
            value: ielts_qualification.trf_number,
            action: 'Change TRF number',
            change_path: candidate_interface_edit_ielts_path,
          },
          {
            key: 'Year awarded',
            value: ielts_qualification.award_year,
            action: 'Change year awarded',
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
