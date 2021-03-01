module CandidateInterface
  class LinksToPreviousApplicationsComponent < ViewComponent::Base
    include ViewHelper

    def initialize(application_form:)
      @application_form = application_form
    end

    def submitted_applications
      @application_form.candidate.application_forms.select(&:submitted?).sort_by(&:submitted_at)
    end

  private

    def ordinalize(application_form)
      "#{TextOrdinalizer.call(ordinal(application_form)).capitalize} application"
    end

    def ordinal(application_form)
      submitted_applications.find_index(application_form).to_i + 1
    end
  end
end
