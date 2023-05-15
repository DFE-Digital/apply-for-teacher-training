module CandidateInterface
  class OfferReferenceConditionReviewComponent < ViewComponent::Base
    attr_accessor :reference_condition

    def initialize(reference_condition:)
      @reference_condition = reference_condition
    end
  end
end
