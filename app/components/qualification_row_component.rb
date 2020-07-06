class QualificationRowComponent < ViewComponent::Base
  validates :qualification, presence: true
  attr_reader :qualification

  def initialize(qualification:)
    @qualification = qualification
  end
end
