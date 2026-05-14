class CandidateInterface::ApplicationChoices::MidCycleCreationLimitContentComponent < ApplicationComponent
  def initialize(application_form:)
    @application_form = application_form
  end

  attr_reader :application_form

  delegate :number_of_in_progress_applications_left, :total_application_limit, :in_progress_limit, to: :application_form

  def show_how_to_add_more_applications? = !show_total_applications_limit?

  def inactive_bullet
    if christmas_or_easter_delay_applications?
      t('mid_cycle_content_component.inactive_with_response_time_warning')
    else
      t('mid_cycle_content_component.inactive')
    end
  end

  def max_number_of_applications
    [application_form.unsuccessful_retry_limit, application_form.in_progress_limit].max
  end

  def apply_reopens_date_text
    application_form.recruitment_cycle_timetable.apply_reopens_at.to_fs(:month_and_year)
  end

private

  def show_total_applications_limit?
    total_application_limit <= in_progress_limit
  end

  def christmas_or_easter_delay_applications?
    christmas_applications? || easter_applications?
  end

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
