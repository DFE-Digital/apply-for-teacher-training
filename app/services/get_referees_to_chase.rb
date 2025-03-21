class GetRefereesToChase
  attr_accessor :chase_referee_by, :rejected_chased_ids
  APPLICATION_STATUSES = ApplicationStateChange::SUCCESSFUL_STATES - [:offer]

  def initialize(chase_referee_by:, rejected_chased_ids:)
    @chase_referee_by = chase_referee_by
    @rejected_chased_ids = rejected_chased_ids
  end

  def call
    ApplicationReference.joins(:application_form)
      .joins(application_form: :application_choices)
      .feedback_requested
      .where(
        application_forms: {
          recruitment_cycle_year: RecruitmentCycleTimetable.current_year,
          application_choices: { status: APPLICATION_STATUSES },
        },
      )
      .where('requested_at < ?', chase_referee_by)
      .where.not(id: rejected_chased_ids)
  end
end
