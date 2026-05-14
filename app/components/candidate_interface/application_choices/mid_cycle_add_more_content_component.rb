class CandidateInterface::ApplicationChoices::MidCycleAddMoreContentComponent < ApplicationComponent
  def initialize(application_form:)
    @application_form = application_form
  end

  attr_reader :application_form

  def christmas_response_time_warning_text
    if christmas_applications?
      govuk_warning_text(text: t('mid_cycle_content_component.christmas_warning'))
    elsif easter_applications?
      govuk_warning_text(text: t('mid_cycle_content_component.easter_warning'))
    end
  end

  def incomplete_details_message
    return if CandidateInterface::CompletedApplicationForm.new(application_form:).valid?

    link = govuk_link_to('your details', candidate_interface_details_path)
    t('mid_cycle_content_component.incomplete_details_message', link:).html_safe
  end

private

  def christmas_applications?
    @christmas_applications ||= application_form.application_choices.awaiting_provider_decision.any? do |application_choice|
      CandidateInterface::HolidayResponseTimeIndicator.new(application_choice:).christmas_response_time_delay_possible?
    end
  end

  def easter_applications?
    @easter_applications ||= application_form.application_choices.awaiting_provider_decision.any? do |application_choice|
      CandidateInterface::HolidayResponseTimeIndicator.new(application_choice:).easter_response_time_delay_possible?
    end
  end
end
