class CandidateInterface::ApplicationChoices::SeptemberStartContentComponent < ApplicationComponent
  delegate :recruitment_cycle_year, :recruitment_cycle_timetable, to: :application_form
  delegate :after_reject_by_default?, :after_decline_by_default?, to: :recruitment_cycle_timetable

  attr_reader :application_form, :with_tabs, :heading_class

  def initialize(application_form:, with_tabs: false, heading: nil, heading_class: 'govuk-heading-l')
    @application_form = application_form
    @with_tabs = with_tabs
    @heading = heading
    @heading_class = heading_class
  end

  def heading
    @heading.presence || "Courses starting by September #{recruitment_cycle_year}"
  end

  def awaiting_provider_decision_content
    if application_form.application_choices.any?(&:state_pending_provider_decision?)
      {
        title: 'Applications awaiting a provider decision',
        content: 'Applications will be rejected automatically at  ' \
                 "#{recruitment_cycle_timetable.reject_by_default_at.to_fs(:govuk_date_time_time_first)} if providers do not respond.",
      }
    end
  end

  def offered_content
    if application_form.application_choices.any?(&:state_offered?)
      {
        title: 'Offers awaiting your response',
        content: 'Offers will be declined automatically at ' \
                 "#{recruitment_cycle_timetable.decline_by_default_at.to_fs(:govuk_date_time_time_first)} if you do not respond.",
      }
    end
  end

  def application_choices
    CandidateInterface::SortApplicationChoices.call(
      application_choices: application_form
                             .application_choices
                             .course_start_in_september(recruitment_cycle_year)
                             .for_sorting,
    )
  end

  def render?
    application_choices.present?
  end
end
