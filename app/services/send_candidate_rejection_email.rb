class SendCandidateRejectionEmail
  include CandidateApplications

  attr_reader :application_choice

  def initialize(application_choice:)
    @application_choice = application_choice
  end

  def call
    if candidate_applications.all?(&:rejected?)
      CandidateMailer.application_rejected_all_applications_rejected(application_choice).deliver_later
    elsif applications_with_offer_and_awaiting_decision?
      CandidateMailer.application_rejected_one_offer_one_awaiting_decision(application_choice).deliver_later
    elsif applications_awaiting_decision_only?
      CandidateMailer.application_rejected_awaiting_decision_only(application_choice).deliver_later
    elsif applications_with_offers_only?
      CandidateMailer.application_rejected_offers_only(application_choice).deliver_later
    end
  end
end
