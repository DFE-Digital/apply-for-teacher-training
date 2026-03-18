class CandidateInterface::ReferenceStatusesComponent < ApplicationComponent
  include ViewHelper

  attr_reader :reference

  def initialize(reference:)
    @reference = reference
  end
end
