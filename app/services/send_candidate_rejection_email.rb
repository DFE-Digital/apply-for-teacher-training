class SendCandidateRejectionEmail
  include CandidateApplications

  attr_reader :application_choice

  def initialize(application_choice:)
    @application_choice = application_choice
  end

  def call
    if application_choice.continuous_applications?
      CandidateMailer.application_rejected(application_choice).deliver_later
    else
      pre_continuous_applications_rejection_mailers
    end
  end

private

  def pre_continuous_applications_rejection_mailers
    if applications_awaiting_decision_only?
      CandidateMailer.application_rejected_awaiting_decision_only(application_choice).deliver_later
    elsif applications_with_offers_only?
      CandidateMailer.application_rejected_offers_only(application_choice).deliver_later
    else
      CandidateMailer.application_rejected_all_applications_rejected(application_choice).deliver_later
    end
  end
end
