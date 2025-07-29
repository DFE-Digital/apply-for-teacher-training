class SendCandidateRejectionEmail
  attr_reader :application_choice

  def initialize(application_choice:)
    @application_choice = application_choice
  end

  def call
    CandidateMailer.application_rejected(application_choice).deliver_later
  end
end
