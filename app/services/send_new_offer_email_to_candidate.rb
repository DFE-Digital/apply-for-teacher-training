class SendNewOfferEmailToCandidate
  attr_accessor :application_choice

  def initialize(application_choice:)
    self.application_choice = application_choice
  end

  def call
    CandidateMailer.new_offer_made(application_choice).deliver_later
  end
end
