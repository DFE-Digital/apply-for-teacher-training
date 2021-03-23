module CandidateInterface
  class ApplicationDashboardGuidanceComponent < ViewComponent::Base
    include ViewHelper

    attr_reader :application_form

    def initialize(application_form:)
      @application_form = application_form
    end

    def no_offers_awaiting_decisions?
      !successful? && awaiting_decisions?
    end

    def awaiting_multiple_decisions?
      multiple_choices_with_status?('awaiting_provider_decision')
    end

    def has_offers_awaiting_decisions?
    end

    def offer_accepted?
    end

    def offer_deferred?
    end

    def conditions_met?
    end

    def number_of_offers_in_words 
      'One'
    end

    def accepted_offer_provider_name 
      ''
    end

  private

    def awaiting_decisions?
      statuses.include?('awaiting_provider_decision')
    end

    def multiple_choices_with_status?(status)
      statuses.select { |s| s == status }.count > 1
    end

    def successful?
      application_form.successful?
    end

    def statuses
      @statuses ||= application_form.application_choices.map(&:status)
    end
  end
end
