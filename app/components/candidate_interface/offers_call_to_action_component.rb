module CandidateInterface
  class OffersCallToActionComponent < ViewComponent::Base
    include ViewHelper
    attr_reader :application_form

    def initialize(application_form:)
      @application_form = application_form
    end

    def title
      "Congratulations on your #{'offer'.pluralize(offer_count)}"
    end

    def message
      "You have #{pluralize(days_left_to_respond, 'day')} (until #{decline_by_default_date.to_s(:govuk_date)}) to respond. If you do not respond, your #{'offer'.pluralize(offer_count)} will automatically be declined."
    end

    def render?
      @application_form.application_choices.any?(&:offer?) &&
        @application_form.provider_decision_made?
    end

  private

    def offer_count
      @application_form.application_choices.offer.count
    end

    def decline_by_default_at
      @application_form.application_choices.offer.map(&:decline_by_default_at).min || Time.zone.now
    end

    def days_left_to_respond
      duration_in_days = (decline_by_default_date.to_date - Date.current).to_i
      [0, duration_in_days].max
    end

    def decline_by_default_date
      @decline_by_default_date ||= @application_form.application_choices.offer.map(&:decline_by_default_at).min
    end
  end
end
