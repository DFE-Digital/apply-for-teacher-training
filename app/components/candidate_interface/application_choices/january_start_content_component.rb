class CandidateInterface::ApplicationChoices::JanuaryStartContentComponent < ApplicationComponent
  delegate :recruitment_cycle_year, :recruitment_cycle_timetable, to: :application_form

  attr_reader :application_form

  def initialize(application_form:)
    @application_form = application_form
  end

  def title
    "Courses starting by January #{recruitment_cycle_year + 1}"
  end

  def provider_deadline_content
    "Providers have until #{recruitment_cycle_timetable.winter_reject_by_default_at.to_fs(:govuk_date_time_time_first)} " \
      'to make decisions on these applications.'
  end

  def application_choices
    return if application_form.blank?

    CandidateInterface::SortApplicationChoices.call(
      application_choices: application_form
                             .application_choices
                             .course_starts_after_september(recruitment_cycle_year)
                             .for_sorting,
    )
  end

  def render?
    application_choices.present?
  end
end
