module ProviderInterface
  class StatusBoxComponent < ActionView::Component::Base
    include ViewHelper

    attr_reader :application_choice

    def initialize(application_choice:)
      @application_choice = application_choice
    end

    def submitted_at
      format_date application_choice.application_form.submitted_at
    end

    def respond_by
      format_date application_choice.reject_by_default_at
    end

    def withdrawn_at
      format_date application_choice.withdrawn_at
    end

    def candidate_respond_by
      format_date application_choice.decline_by_default_at
    end

    def rejected_at
      format_date application_choice.rejected_at
    end

    def accepted_at
      format_date application_choice.accepted_at
    end

    def declined_at
      format_date application_choice.declined_at
    end

    def recruited_at
      format_date application_choice.recruited_at
    end

    def conditions_not_met_at
      format_date application_choice.conditions_not_met_at
    end

    def enrolled_at
      format_date application_choice.enrolled_at
    end

  private

    def format_date(date)
      date&.to_s(:govuk_date) || ''
    end
  end
end
