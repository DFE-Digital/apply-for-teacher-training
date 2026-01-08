module CandidateInterface
  class OfferReferenceConditionReviewComponent < BaseComponent
    attr_accessor :reference_condition

    def initialize(reference_condition:)
      @reference_condition = reference_condition
    end
  end
end
