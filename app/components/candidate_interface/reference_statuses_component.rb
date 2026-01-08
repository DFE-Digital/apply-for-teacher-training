class CandidateInterface::ReferenceStatusesComponent < BaseComponent
  include ViewHelper

  attr_reader :reference

  def initialize(reference:)
    @reference = reference
  end
end
