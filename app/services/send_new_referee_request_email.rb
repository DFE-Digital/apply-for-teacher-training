class SendNewRefereeRequestEmail
  def self.call(reference:, reason: :not_responded)
    CandidateMailer.new_referee_request(reference, reason: reason).deliver_later
    ChaserSent.create!(chaser_type: :reference_replacement, chased: reference)
  end
end
