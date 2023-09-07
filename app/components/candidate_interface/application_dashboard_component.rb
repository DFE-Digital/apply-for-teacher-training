module CandidateInterface
  class ApplicationDashboardComponent < ViewComponent::Base
    include ViewHelper

    attr_reader :application_form

    def initialize(application_form:)
      @application_form = application_form
    end

    def before_render
      @title = t('page_titles.application_dashboard')
    end

    def title
      return @title unless multiple_choices? || multiple_applications?

      @title&.pluralize
    end

  private

    def multiple_choices?
      @application_form.application_choices.size > 1
    end

    def multiple_applications?
      @application_form.previous_application_form.present? ||
        @application_form.subsequent_application_form.present?
    end

    def offers_received_and_all_providers_responded?
      @application_form.application_choices.any?(&:offer?) &&
        @application_form.provider_decision_made?
    end
  end
end
