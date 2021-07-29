class SendNewCycleHasStartedEmailToCandidate
  def self.call(application_form:)
    CandidateMailer.new_cycle_has_started(application_form).deliver_later
    ChaserSent.create!(chased: application_form, chaser_type: :new_cycle_has_started)
  end
end
