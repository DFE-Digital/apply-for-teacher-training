class SendNewCycleHasStartedEmailToCandidatesWorker
  include Sidekiq::Worker

  BATCH_SIZE = 120

  def perform
    return unless EndOfCycle::CandidateEmailTimetabler.new.send_new_cycle_has_started_email?

    BatchDelivery.new(
      relation:,
      stagger_over: 12.hours,
      batch_size: BATCH_SIZE,
    ).each do |batch_time, records|
      SendNewCycleHasStartedEmailToCandidatesBatchWorker.perform_at(
        batch_time,
        records.pluck(:id),
      )
    end
  end

  def relation
    previous_recruitment_year = RecruitmentCycleTimetable.previous_year
    current_recruitment_year = RecruitmentCycleTimetable.current_year
    # Candidates who didn't have successful applications last year and haven't started working on their 2025 application
    Candidate
      .for_marketing_or_nudge_emails
      .joins(:application_forms)
      # Has not started a new application form
      .where.not(id: Candidate.joins(:application_forms).where(
        application_forms: { recruitment_cycle_year: current_recruitment_year },
      ))
      # The previous year's application form did not have any successful choices.
      .where(
        '(application_forms.recruitment_cycle_year = (:previous_recruitment_year) AND NOT EXISTS (:successful))',
        previous_recruitment_year:,
        successful: ApplicationChoice
                      .select(1)
                      .where(status: ApplicationStateChange::SUCCESSFUL_STATES)
                      .where('application_choices.application_form_id = application_forms.id'),
      )
      .distinct
  end
end
