class SendCandidateRejectionEmail
  attr_accessor :application_choice

  def initialize(application_choice:)
    self.application_choice = application_choice
  end

  def call
    candidate_application_choices = application_choice.application_form.application_choices
    number_of_pending_decisions = candidate_application_choices.awaiting_provider_decision.count
    number_of_offers = candidate_application_choices.offer.count

    if candidate_application_choices.all?(&:rejected?)
      CandidateMailer.send(:application_rejected_all_rejected, application_choice).deliver_later
    elsif number_of_pending_decisions.positive?
      CandidateMailer.send(:application_rejected_awaiting_decisions, application_choice).deliver_later
    elsif number_of_offers.positive?
      CandidateMailer.send(:application_rejected_offers_made, application_choice).deliver_later
    end
  end
end
