module ProviderInterface
  class ApplicationOfferWithdrawnFeedbackComponent < ApplicationComponent
    attr_reader :application_choice

    def initialize(application_choice:)
      @application_choice = application_choice
    end

    def render?
      application_choice.offer_withdrawn?
    end
  end
end
