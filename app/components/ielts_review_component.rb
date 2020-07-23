class IeltsReviewComponent < ViewComponent::Base
  include Rails.application.routes.url_helpers

  attr_reader :ielts_qualification

  def initialize(ielts_qualification)
    @ielts_qualification = ielts_qualification
  end

  def ielts_rows
    [
      {
        key: 'Do you have an English as a foreign language qualification?',
        value: 'Yes',
        action: 'Change whether or not you have a qualification',
        change_path: candidate_interface_english_foreign_language_edit_start_path,
      },
      {
        key: 'Type of qualification',
        value: 'IELTS',
        action: 'Change type of qualification',
        change_path: candidate_interface_english_foreign_language_type_path,
      },
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
