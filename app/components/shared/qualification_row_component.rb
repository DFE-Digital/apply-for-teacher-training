# NOTE: This component is used by both provider and support UIs
class QualificationRowComponent < ViewComponent::Base
  attr_reader :qualification

  def initialize(qualification:)
    @qualification = qualification
  end

  def country
    qualification.international? ? COUNTRIES_AND_TERRITORIES[qualification.institution_country] : 'United Kingdom'
  end
end
