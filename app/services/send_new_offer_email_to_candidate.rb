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
    add_comment_to_audit_trail
  end

private

  def add_comment_to_audit_trail
    audit_comment =
      "New offer email sent to candidate #{application_choice.application_form.candidate.email_address} for " +
      "#{application_choice.course_option.course.name_and_code} at #{application_choice.course_option.course.provider.name}."
    application_choice.application_form.update!(audit_comment: audit_comment)
  end

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
