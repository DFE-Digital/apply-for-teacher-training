class SendDeferredOfferReminderEmailToCandidate
  def self.call(application_choice:)
    CandidateMailer.deferred_offer_reminder(application_choice).deliver_later
  end
end
