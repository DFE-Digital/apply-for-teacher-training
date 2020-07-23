class OtherEflQualificationReviewComponent < ViewComponent::Base
  include Rails.application.routes.url_helpers

  attr_reader :other_qualification

  def initialize(other_qualification)
    @other_qualification = other_qualification
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
        value: other_qualification.name,
        action: 'Change type of qualification',
        change_path: candidate_interface_english_foreign_language_type_path,
      },
      {
        key: 'Score or grade',
        value: other_qualification.grade,
        action: 'Change score or grade',
        change_path: candidate_interface_edit_other_efl_qualification_path,
      },
      {
        key: 'Year awarded',
        value: other_qualification.award_year,
        action: 'Change year awarded',
        change_path: candidate_interface_edit_other_efl_qualification_path,
      },
    ]
  end
end
