class CancelUnsubmittedApplicationsWorker
  include Sidekiq::Worker

  def perform
    unsubmitted_applications_from_earlier_cycle.each do |application_form|
      CandidateInterface::CancelUnsubmittedApplicationAtEndOfCycle.new(application_form).call
    end
  end

private

  def unsubmitted_applications_from_earlier_cycle
    return [] unless CycleTimetable.cancel_unsubmitted_applications?

    ApplicationForm
      .current_cycle
      .where.not(application_forms: { candidate_id: Candidate.where(hide_in_reporting: true).select(:id) })
      .includes(:application_choices).where('application_choices.status': 'unsubmitted')
      .distinct
  end
end
