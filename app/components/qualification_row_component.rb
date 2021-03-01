# NOTE: This component is used by both provider and support UIs
class QualificationRowComponent < ViewComponent::Base
  attr_reader :qualification

  def initialize(qualification:)
    @qualification = qualification
  end
end
