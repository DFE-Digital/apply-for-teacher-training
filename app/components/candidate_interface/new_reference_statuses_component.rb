class CandidateInterface::NewReferenceStatusesComponent < ViewComponent::Base
  include ViewHelper

  attr_reader :reference

  def initialize(reference:)
    @reference = reference
  end
end
