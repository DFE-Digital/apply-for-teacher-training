class SendChaseEmailToCandidate
  def self.call(application_form:)
    unless application_form.continuous_applications?
      ChaserSent.create!(chased: application_form, chaser_type: :candidate_decision_request)
    end
  end
end
