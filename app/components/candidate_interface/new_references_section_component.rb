class CandidateInterface::NewReferencesSectionComponent < ViewComponent::Base
  include ViewHelper

  def initialize(presenter)
    @presenter = presenter
  end
end
