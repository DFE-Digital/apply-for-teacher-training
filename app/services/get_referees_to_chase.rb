class GetRefereesToChase
  attr_accessor :chase_referee_by, :rejected_chased_ids
  APPLICATION_STATUSES = ApplicationStateChange.successful - [:offer]

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
          recruitment_cycle_year: RecruitmentCycle.current_year,
          application_choices: { status: APPLICATION_STATUSES },
        }.merge(only_chase_apply_again_references),
      )
      .where('requested_at < ?', chase_referee_by)
      .where.not(id: rejected_chased_ids)
  end

  def only_chase_apply_again_references
    if CycleTimetable.between_apply_1_deadline_and_find_closes?
      { phase: 'apply_2' }
    else
      {}
    end
  end
end
