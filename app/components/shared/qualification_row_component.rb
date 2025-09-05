# NOTE: This component is used by both provider and support UIs
class QualificationRowComponent < ApplicationComponent
  attr_reader :qualification, :editable

  def initialize(qualification:, editable: false)
    @qualification = qualification
    @editable = editable
  end

  def country
    international? ? CountryFinder.find_name_from_iso_code(qualification.institution_country) : 'United Kingdom'
  end

private

  def international?
    qualification.international? || qualification.non_uk_qualification_type?
  end
end
