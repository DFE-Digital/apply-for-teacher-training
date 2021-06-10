module ProviderInterface
  class ConditionsComponent < ViewComponent::Base
    include ViewHelper

    attr_reader :application_choice

    def initialize(application_choice:)
      @application_choice = application_choice
    end

    def render?
      application_choice.offer.present?
    end

    def conditions
      application_choice.offer.conditions
    end
  end
end
