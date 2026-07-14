class CandidateInterface::ApplicationChoices::JanuaryStartContentComponent < ApplicationComponent
  delegate :recruitment_cycle_year, :recruitment_cycle_timetable, to: :application_form
  delegate :after_winter_reject_by_default?, :after_winter_decline_by_default?, :winter_reject_by_default_at,
           :approaching_winter_reject_by_default?, :relative_next_year, to: :recruitment_cycle_timetable

  attr_reader :application_form

  def initialize(application_form:)
    @application_form = application_form
  end

  def title
    I18n.t('candidate_interface.application_choices.january_start_component.title', year: relative_next_year)
  end

  def provider_deadline_content
    return if after_winter_reject_by_default?

    I18n.t(
      'candidate_interface.application_choices.january_start_component.provider_deadline_content',
      reject_by: recruitment_cycle_timetable.winter_reject_by_default_at.to_fs(:govuk_date_time_time_first),
    )
  end

  def awaiting_provider_decision_content
    if application_choices.any?(&:decision_pending?)
      {
        title: I18n.t(
          'candidate_interface.application_choices.january_start_component.awaiting_provider_decision_content.title',
        ),
        content: I18n.t(
          'candidate_interface.application_choices.january_start_component.awaiting_provider_decision_content.rejected automatically',
          reject_by: recruitment_cycle_timetable.winter_reject_by_default_at.to_fs(:govuk_date_time_time_first),
        ),
      }
    end
  end

  def reject_by_default_explanation
    return unless application_choices.any?(&:rejected_by_default?)

    I18n.t(
      'candidate_interface.application_choices.january_start_component.reject_by_default_explanation',
    )
  end

  def decline_by_default_explanation
    return unless application_choices.any?(&:declined_by_default?)

    I18n.t(
      'candidate_interface.application_choices.january_start_component.decline_by_default_explanation',
    )
  end

  def offered_content
    if application_choices.any?(&:offer?)
      {
        title: I18n.t(
          'candidate_interface.application_choices.january_start_component.offered_content.title',
        ),
        content: I18n.t(
          'candidate_interface.application_choices.january_start_component.offered_content.declined automatically',
          decline_by: recruitment_cycle_timetable.winter_decline_by_default_at.to_fs(:govuk_date_time_time_first),
        ),
      }
    end
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
