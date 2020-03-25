class SendNewOfferEmailToCandidate
  attr_accessor :application_choice

  def initialize(application_choice:)
    self.application_choice = application_choice
  end

  def call
    CandidateMailer.send(
      "new_offer_#{mail_type(application_choice)}".to_sym,
      application_choice,
    ).deliver_later
  end

private

  def mail_type(application_choice)
    candidate_application_choices = application_choice.application_form.application_choices
    number_of_pending_decisions = candidate_application_choices.select(&:awaiting_provider_decision?).count
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
