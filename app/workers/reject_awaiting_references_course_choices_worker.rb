class RejectAwaitingReferencesCourseChoicesWorker
  include Sidekiq::Worker

  def perform
    CandidateInterface::GetPreviousCyclesAwaitingReferencesApplications.call.each do |application_form|
      application_form.application_choices.each do |application_choice|
        CandidateInterface::RejectAwaitingReferencesApplication.call(application_choice)
      end
      CandidateMailer.application_on_pause(application_form).deliver_later
    end
  end
end
