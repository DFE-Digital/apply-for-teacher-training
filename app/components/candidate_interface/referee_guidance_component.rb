module CandidateInterface
  class RefereeGuidanceComponent < ViewComponent::Base
    attr_reader :application_form

    def initialize(application_form:)
      @application_form = application_form
    end

    def pluralize_provider
      'provider'.pluralize(provider_count)
    end

    def reject_by_default_days
      @reject_by_default_days ||= TimeLimitCalculator.new(
        rule: :reject_by_default,
        effective_date: @application_form&.application_choices&.first&.sent_to_provider_at || Time.zone.now,
      ).call[:days]
    end

  private

    def provider_count
      @application_form.application_choices.map(&:provider).uniq.count
    end
  end
end
