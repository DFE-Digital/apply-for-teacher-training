class CancelUnsubmittedApplicationsWorker
  include Sidekiq::Worker

  def perform
    # return unless CycleTimetable.cancel_unsubmitted_applications?

    unsubmitted_applications_from_earlier_cycle.find_each do |application_form|
      CandidateInterface::CancelUnsubmittedApplicationAtEndOfCycle.new(application_form).call
    end
  end

private

  def unsubmitted_applications_from_earlier_cycle
    ApplicationForm
      .current_cycle
      .includes(:application_choices).where('application_choices.status': 'unsubmitted')
      .distinct
  end
end
