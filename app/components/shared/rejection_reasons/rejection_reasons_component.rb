##
# This component class supports the rendering of rejection reasons from the current iteration of structured rejection reasons.
# See https://github.com/DFE-Digital/apply-for-teacher-training/blob/main/docs/app_concepts/reasons-for-rejection.md
#
class RejectionReasons::RejectionReasonsComponent < ApplicationComponent
  include ViewHelper

  attr_reader :application_choice, :editable

  def initialize(application_choice:, render_link_to_find_when_rejected_on_qualifications: false, editable: false)
    @application_choice = application_choice
    @render_link_to_find_when_rejected_on_qualifications = render_link_to_find_when_rejected_on_qualifications
    @editable = editable
  end

  def link_to_find_when_rejected_on_qualifications
    link = govuk_link_to(
      t('service_name.find'),
      "#{@application_choice.course.find_url}#section-entry",
    )

    "View the course requirements on #{link}.".html_safe
  end

  def editable?
    editable
  end

  def reasons
    ::RejectionReasons.new(application_choice.structured_rejection_reasons).selected_reasons
  end

  def render_link_to_find?(reason)
    reason.id == 'qualifications' && @render_link_to_find_when_rejected_on_qualifications
  end
end
