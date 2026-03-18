module CandidateInterface
  class OfferReferenceConditionReviewComponent < ApplicationComponent
    attr_accessor :reference_condition

    def initialize(reference_condition:)
      @reference_condition = reference_condition
    end
  end
end
