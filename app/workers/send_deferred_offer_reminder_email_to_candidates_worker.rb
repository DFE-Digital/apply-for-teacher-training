class SendDeferredOfferReminderEmailToCandidatesWorker < ApplicationJob
  def perform
    GetDeferredApplicationChoicesForCurrentCycle.call.each do |application_choice|
      SendDeferredOfferReminderEmailToCandidate.call(application_choice:)
    end
  end
end
