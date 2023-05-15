module CandidateInterface
  class ReferenceConditionHeaderComponent < ViewComponent::Base
    attr_accessor :reference_condition, :provider_name
    delegate :description, :met?, to: :reference_condition, allow_nil: true

    def initialize(reference_condition:, provider_name:)
      @reference_condition = reference_condition
      @provider_name = provider_name
    end

    def render?
      !met?
    end
  end
end
