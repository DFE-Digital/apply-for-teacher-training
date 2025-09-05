##
# This component class supports the rendering of rejection reasons from the initial iteration of structured rejection reasons.
# See https://github.com/DFE-Digital/apply-for-teacher-training/blob/main/docs/app_concepts/reasons-for-rejection.md
#
module CandidateInterface
  class RejectionReasons::ReasonsForRejectionComponent < ApplicationComponent
    include ViewHelper

    attr_reader :application_choice

    def initialize(application_choice:, render_link_to_find_when_rejected_on_qualifications: false)
      @application_choice = application_choice
      @render_link_to_find_when_rejected_on_qualifications = render_link_to_find_when_rejected_on_qualifications
    end

    def link_to_find_when_rejected_on_qualifications
      link = govuk_link_to(
        t('service_name.find'),
        "#{@application_choice.course.find_url}#section-entry",
      )

      "View the course requirements on #{link}.".html_safe
    end

    def reasons
      ::ReasonsForRejection.new(application_choice.structured_rejection_reasons)
    end
  end
end
