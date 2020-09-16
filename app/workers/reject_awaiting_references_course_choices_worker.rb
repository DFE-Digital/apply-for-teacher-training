class RejectAwaitingReferencesCourseChoicesWorker
  include Sidekiq::Worker

  def perform
    CandidateInterface::GetPreviousCyclesAwaitingReferencesApplications.call.each do |application_form|
      application_form.application_choices.awaiting_references.each do |application_choice|
        CandidateInterface::RejectAwaitingReferencesApplication.call(application_choice)
      end

      application_form.application_references.each do |application_reference|
        CandidateInterface::CancelReferenceAtEndOfCycle.call(application_reference)
      end

      CandidateMailer.referees_did_not_respond_before_end_of_cycle(application_form).deliver_later
    end
  end
end
