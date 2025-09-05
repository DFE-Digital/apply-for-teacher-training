module CandidateInterface
  class OfferConditionsReviewComponent < ApplicationComponent
    def initialize(conditions:, provider:, application_form:)
      @conditions = conditions
      @provider = provider
      @application_form = application_form
    end

  private

    attr_reader :conditions, :provider, :application_form
  end
end
