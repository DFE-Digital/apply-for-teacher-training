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

  private

    def format_date(date)
      date.strftime('%-e %B %Y')
    end
  end
end
