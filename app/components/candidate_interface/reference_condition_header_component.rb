module CandidateInterface
  class ReferenceConditionHeaderComponent < ApplicationComponent
    attr_accessor :reference_condition, :provider_name, :show_extra_content
    delegate :description, :met?, to: :reference_condition, allow_nil: true

    def initialize(reference_condition:, provider_name:, show_extra_content: true)
      @reference_condition = reference_condition
      @provider_name = provider_name
      @show_extra_content = show_extra_content
    end

    def render?
      !met?
    end

    def show_extra_content?
      @show_extra_content.present?
    end
  end
end
