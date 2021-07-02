class CancelUnsubmittedApplicationsWorker
  include Sidekiq::Worker

  def perform
    unsubmitted_applications_from_earlier_cycle.each do |application_form|
      CandidateInterface::CancelUnsubmittedApplicationAtEndOfCycle.new(application_form).call
    end
  end

private

  def unsubmitted_applications_from_earlier_cycle
    return [] unless CycleTimetable.between_cycles_apply_2?

    ApplicationForm
      .where(submitted_at: nil)
      .where(recruitment_cycle_year: RecruitmentCycle.current_year)
      .where(
        'application_forms.candidate_id NOT IN (:hidden_candidates)',
        hidden_candidates: Candidate.where(hide_in_reporting: true).select(:id),
      )
      .where(
        'application_forms.id IN (:unsubmitted_application_choices)',
        unsubmitted_application_choices: ApplicationChoice.unsubmitted.select(:application_form_id),
      )
      .includes(:application_choices)
      .distinct
  end
end
