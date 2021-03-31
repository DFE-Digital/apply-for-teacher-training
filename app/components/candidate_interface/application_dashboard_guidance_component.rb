module CandidateInterface
  class ApplicationDashboardGuidanceComponent < ViewComponent::Base
    include ViewHelper

    attr_reader :application_form

    NUMBER_IN_WORDS = {
      1 => 'One',
      2 => 'Two',
      3 => 'Three',
    }.freeze

    def initialize(application_form:)
      @application_form = application_form
    end

    def no_offers_awaiting_decisions?
      !successful? && awaiting_decisions?
    end

    def has_multiple_applications?
      statuses.count > 1
    end

    def has_multiple_offers_but_awaiting_decisions?
      has_offers_but_awaiting_decisions? && has_multiple_offers?
    end

    def has_single_offer_but_awaiting_decisions?
      has_offers_but_awaiting_decisions? && !has_multiple_offers?
    end

    def has_offers_but_awaiting_decisions?
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

    def has_multiple_offers?
      multiple_choices_with_status?('offer')
    end

    def number_of_offers_in_words
      count = statuses.select { |s| s == 'offer' }.count
      NUMBER_IN_WORDS[count] || count.to_s
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
