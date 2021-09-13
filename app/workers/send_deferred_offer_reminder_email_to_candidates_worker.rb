class SendDeferredOfferReminderEmailToCandidatesWorker
  include Sidekiq::Worker
  include SafePerformAsync

  def perform
    GetDeferredApplicationChoicesForCurrentCycle.call.each do |application_choice|
      SendDeferredOfferReminderEmailToCandidate.call(application_choice: application_choice)
    end
  end
end
