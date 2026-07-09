class CandidateInterface::ApplicationChoices::JanuaryStartContentComponent < ApplicationComponent
  delegate :recruitment_cycle_year, :recruitment_cycle_timetable, to: :application_form
  delegate :after_winter_reject_by_default?, :after_winter_decline_by_default?, :winter_reject_by_default_at,
           :approaching_winter_reject_by_default?, to: :recruitment_cycle_timetable

  attr_reader :application_form

  def initialize(application_form:)
    @application_form = application_form
  end

  def title
    "Courses starting by January #{recruitment_cycle_year + 1}"
  end

  def provider_deadline_content
    return if after_winter_reject_by_default?

    "Providers have until #{recruitment_cycle_timetable.winter_reject_by_default_at.to_fs(:govuk_date_time_time_first)} " \
      'to make decisions on these applications.'
  end

  def awaiting_provider_decision_content
    if application_choices.any?(&:decision_pending?)
      {
        title: 'Applications awaiting a provider decision',
        content: 'Applications will be rejected automatically at ' \
                 "#{recruitment_cycle_timetable.winter_reject_by_default_at.to_fs(:govuk_date_time_time_first)} if providers do not respond.",
      }
    end
  end

  def reject_by_default_explanation
    return unless application_choices.any?(&:rejected_by_default?)

    'Some of your applications have been rejected because the provider did not respond before the deadline.'
  end

  def decline_by_default_explanation
    return unless application_choices.any?(&:declined_by_default?)

    'Some of your offers have been declined because you did not respond before the deadline.'
  end

  def offered_content
    if application_choices.any?(&:offer?)
      {
        title: 'Offers awaiting your response',
        content: 'Offers will be declined automatically at ' \
                 "#{recruitment_cycle_timetable.winter_decline_by_default_at.to_fs(:govuk_date_time_time_first)} if you do not respond.",
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
