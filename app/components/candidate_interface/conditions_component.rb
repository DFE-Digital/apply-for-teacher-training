module CandidateInterface
  class ConditionsComponent < ApplicationComponent
    include ViewHelper

    attr_reader :application_choice

    delegate :offer, to: :application_choice
    delegate :conditions, to: :offer

    def initialize(application_choice:)
      @application_choice = application_choice
    end

    def render?
      offer.present?
    end
  end
end
