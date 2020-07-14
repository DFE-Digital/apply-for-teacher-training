class ToeflReviewComponent < ViewComponent::Base
  attr_reader :toefl_qualification

  def initialize(toefl_qualification)
    @toefl_qualification = toefl_qualification
  end

  def toefl_rows
    [
      {
        key: 'Do you have an English as a foreign language qualification?',
        value: 'Yes',
        action: 'Change',
        change_path: '',
      },
      {
        key: 'Type of qualification',
        value: 'TOEFL',
        action: 'Change',
        change_path: '',
      },
      {
        key: 'TOEFL registration number',
        value: toefl_qualification.registration_number,
        action: 'Change',
        change_path: candidate_interface_edit_toefl_path,
      },
      {
        key: 'Year awarded',
        value: toefl_qualification.award_year,
        action: 'Change',
        change_path: candidate_interface_edit_toefl_path,
      },
      {
        key: 'Total score',
        value: toefl_qualification.total_score,
        action: 'Change',
        change_path: candidate_interface_edit_toefl_path,
      },
    ]
  end
end
