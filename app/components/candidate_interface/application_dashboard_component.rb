module CandidateInterface
  class ApplicationDashboardComponent < ViewComponent::Base
    include ViewHelper

    attr_reader :application_form

    def initialize(application_form:)
      @application_form = application_form
    end

    def title
      title = t('page_titles.application_dashboard')
      title = title.pluralize if has_multiple_choices? || has_multiple_applications?
      title
    end

  private

    def has_multiple_choices?
      @application_form.application_choices.size > 1
    end

    def has_multiple_applications?
      @application_form.previous_application_form.present? ||
        @application_form.subsequent_application_form.present?
    end
    
    def offers_received_and_all_providers_responded?
      @application_form.application_choices.any?(&:offer?) &&
        @application_form.provider_decision_made?
    end
  end
end
