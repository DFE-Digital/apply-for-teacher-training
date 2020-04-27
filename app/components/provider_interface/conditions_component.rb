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
      application_choice.offer['conditions']
    end

    def condition_rows
      conditions && conditions.empty? ? ['No conditions have been specified'] : conditions
    end

    def application_state
      @application_state ||= ApplicationStateChange.new(application_choice)
    end

    def conditions_met?
      application_state.current_state >= :recruited
    end

    def known_conditions_state?
      conditions_met? || application_state.conditions_not_met?
    end
  end
end
