# NOTE: This component is used by both provider and support UIs
class QualificationRowComponent < ViewComponent::Base
  attr_reader :qualification, :editable

  def initialize(qualification:, editable: false)
    @qualification = qualification
    @editable = editable
  end

  def country
    qualification.international? ? COUNTRIES_AND_TERRITORIES[qualification.institution_country] : 'United Kingdom'
  end
end
