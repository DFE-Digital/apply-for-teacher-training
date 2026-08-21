class CandidateInterface::ApplicationChoices::SeptemberStartContentComponent < ApplicationComponent
  delegate :recruitment_cycle_year, :recruitment_cycle_timetable, to: :application_form

  attr_reader :application_form, :with_tabs, :heading_class

  def initialize(application_form:, with_tabs: false, heading: nil, heading_class: 'govuk-heading-l')
    @application_form = application_form
    @with_tabs = with_tabs
    @heading = heading
    @heading_class = heading_class
  end

  def heading
    return @heading if @heading.present?

    start_dates = application_choices.map do |ac|
      ac.course.start_date.to_fs(:month_and_year)
    end.uniq

    if start_dates.many?
      I18n.t('candidate_interface.application_choices.september_start_component.heading_multiple_start_months', year: recruitment_cycle_year)
    else
      I18n.t('candidate_interface.application_choices.september_start_component.heading_single_start_month', month_and_year: start_dates.first)
    end
  end

  def awaiting_provider_decision_content
    if application_choices.any?(&:decision_pending?)
      {
        title: I18n.t('candidate_interface.application_choices.september_start_component.awaiting_provider_decision_content.title'),
        content: I18n.t(
          'candidate_interface.application_choices.september_start_component.awaiting_provider_decision_content.rejected automatically',
          reject_by: recruitment_cycle_timetable.reject_by_default_at.to_fs(:govuk_date_time_time_first),
        ),
      }
    end
  end

  def reject_by_default_explanation
    return unless application_choices.any?(&:rejected_by_default?)

    I18n.t('candidate_interface.application_choices.september_start_component.reject_by_default_explanation')
  end

  def decline_by_default_explanation
    return unless application_choices.any?(&:declined_by_default?)

    I18n.t('candidate_interface.application_choices.september_start_component.decline_by_default_explanation')
  end

  def offered_content
    if application_choices.any?(&:offer?)
      {
        title: I18n.t('candidate_interface.application_choices.september_start_component.offered_content.title'),
        content: I18n.t(
          'candidate_interface.application_choices.september_start_component.offered_content.declined_automatically',
          decline_by: recruitment_cycle_timetable.decline_by_default_at.to_fs(:govuk_date_time_time_first),
        ),
      }
    end
  end

  def application_choices
    cycle_year = if RecruitmentCycleTimetable.current_timetable.before_apply_opens?
                   RecruitmentCycleTimetable.previous_year
                 else
                   RecruitmentCycleTimetable.current_year
                 end

    CandidateInterface::SortApplicationChoices.call(
      application_choices: application_form
                             .application_choices
                             .course_start_in_september(cycle_year)
                             .for_sorting,
    )
  end

  def render?
    application_choices.present? && recruitment_cycle_timetable.current_year?
  end
end
