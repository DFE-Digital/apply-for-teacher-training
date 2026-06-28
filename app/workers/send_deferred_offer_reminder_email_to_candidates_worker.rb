class SendDeferredOfferReminderEmailToCandidatesWorker < ApplicationJob
  self.queue_adapter = :solid_queue

  def perform
    GetDeferredApplicationChoicesForCurrentCycle.call.each do |application_choice|
      SendDeferredOfferReminderEmailToCandidate.call(application_choice:)
    end
  end
end
