class IeltsReviewComponent < ViewComponent::Base
  attr_reader :ielts_qualification

  def initialize(ielts_qualification)
    @ielts_qualification = ielts_qualification
  end

  def ielts_rows
    [
      {
        key: 'Do you have an English as a foreign language qualification?',
        value: 'Yes',
        action: 'Change',
        change_path: '',
      },
      {
        key: 'Type of qualification',
        value: 'IELTS',
        action: 'Change',
        change_path: '',
      },
      {
        key: 'Test report form (TRF) number',
        value: ielts_qualification.trf_number,
        action: 'Change',
        change_path: candidate_interface_edit_ielts_path,
      },
      {
        key: 'Year awarded',
        value: ielts_qualification.award_year,
        action: 'Change',
        change_path: candidate_interface_edit_ielts_path,
      },
      {
        key: 'Overall band score',
        value: ielts_qualification.band_score,
        action: 'Change',
        change_path: candidate_interface_edit_ielts_path,
      },
    ]
  end
end
