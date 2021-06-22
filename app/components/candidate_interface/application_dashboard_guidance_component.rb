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

    def multiple_applications?
      statuses.count > 1
    end

    def multiple_offers_but_awaiting_decisions?
      offers_but_awaiting_decisions? && multiple_offers?
    end

    def single_offer_but_awaiting_decisions?
      offers_but_awaiting_decisions? && !multiple_offers?
    end

    def offers_but_awaiting_decisions?
      offered? && awaiting_decisions?
    end

    def offer_accepted?
      statuses.include?('pending_conditions')
    end

    def offer_deferred?
      statuses.include?('offer_deferred')
    end

    def conditions_met?
      statuses.include?('recruited')
    end

    def multiple_offers?
      multiple_choices_with_status?('offer')
    end

    def accepted_offer_provider_name
      accepted_application_choice = application_form.application_choices.includes(%i[course provider]).select { |application_choice| %w[pending_conditions recruited].include?(application_choice.status) }.first
      accepted_application_choice.provider.name
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

    def offered?
      statuses.include?('offer')
    end

    def statuses
      @statuses ||= application_form.application_choices.map(&:status)
    end
  end
end
