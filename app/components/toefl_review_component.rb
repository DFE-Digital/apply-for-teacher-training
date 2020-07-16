class ToeflReviewComponent < ViewComponent::Base
  include Rails.application.routes.url_helpers

  attr_reader :toefl_qualification

  def initialize(toefl_qualification)
    @toefl_qualification = toefl_qualification
  end

  def toefl_rows
    [
      {
        key: 'Do you have an English as a foreign language qualification?',
        value: 'Yes',
        action: 'Change whether or not you have a qualification',
        change_path: candidate_interface_english_foreign_language_root_path,
      },
      {
        key: 'Type of qualification',
        value: 'TOEFL',
        action: 'Change type of qualification',
        change_path: candidate_interface_english_foreign_language_type_path,
      },
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
