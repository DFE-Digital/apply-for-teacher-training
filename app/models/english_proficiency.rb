class EnglishProficiency < ApplicationRecord
  include PublishedInAPI

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

    "Name: #{efl_qualification.name}, Grade: #{efl_qualification.grade}, Awarded: #{efl_qualification.award_year}"
  end
end
