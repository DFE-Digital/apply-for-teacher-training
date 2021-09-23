class SendFindHasOpenedEmailToCandidate
  def self.call(application_form:)
    CandidateMailer.find_has_opened(application_form).deliver_later
    ChaserSent.create!(chased: application_form, chaser_type: :find_has_opened)
  end
end
