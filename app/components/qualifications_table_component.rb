class QualificationsTableComponent < ViewComponent::Base
  attr_reader :qualifications, :header

  def initialize(qualifications:, header:)
    @qualifications = qualifications
    @header = header
  end
end
