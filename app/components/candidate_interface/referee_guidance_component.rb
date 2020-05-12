module CandidateInterface
  class RefereeGuidanceComponent < ViewComponent::Base
    attr_reader :application_form

    def initialize(application_form:)
      @application_form = application_form
    end

    def pluralize_provider
      'provider'.pluralize(provider_count)
    end

  private

    def provider_count
      @application_form.application_choices.map(&:provider).uniq.count
    end
  end
end
