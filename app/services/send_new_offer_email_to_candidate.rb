class SendNewOfferEmailToCandidate
  attr_accessor :application_choice

  def initialize(application_choice:)
    self.application_choice = application_choice
  end

  def call
    if application_choice.continuous_applications?
      CandidateMailer.new_offer_made(application_choice).deliver_later
    else
      pre_continuous_applications_withdrawn_mailers
    end
  end

private

  def pre_continuous_applications_withdrawn_mailers
    CandidateMailer.send(
      "new_offer_#{mail_type(application_choice)}".to_sym,
      application_choice,
    ).deliver_later
  end

  def mail_type(application_choice)
    candidate_application_choices = application_choice.self_and_siblings
    number_of_pending_decisions = candidate_application_choices.decision_pending.count
    number_of_offers = candidate_application_choices.select(&:offer?).count

    if number_of_pending_decisions.positive?
      :decisions_pending
    elsif number_of_offers > 1
      :multiple_offers
    else
      :single_offer
    end
  end
end
