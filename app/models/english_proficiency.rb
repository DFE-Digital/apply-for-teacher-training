class EnglishProficiency < ApplicationRecord
  include TouchApplicationChoices

  audited associated_with: :application_form

  belongs_to :application_form
  belongs_to :efl_qualification, polymorphic: true, optional: true, dependent: :destroy

  enum qualification_status: {
    has_qualification: 'has_qualification',
    no_qualification: 'no_qualification',
    qualification_not_needed: 'qualification_not_needed',
  }

  def formatted_qualification_description
    return if efl_qualification.blank?

    name = "Name: #{efl_qualification.name}"
    grade = "Grade: #{efl_qualification.grade}"
    award_year = "Awarded: #{efl_qualification.award_year}"
    reference = "Reference: #{efl_qualification.unique_reference_number}" if efl_qualification.unique_reference_number.present?

    [name, grade, award_year, reference].compact.join(', ')
  end
end
