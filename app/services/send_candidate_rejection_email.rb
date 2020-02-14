class SendCandidateRejectionEmail
  attr_accessor :application_choice

  def initialize(application_choice:)
    self.application_choice = application_choice
  end

  def call
    candidate_application_choices = application_choice.application_form.application_choices
    number_of_pending_decisions = candidate_application_choices.select(&:awaiting_provider_decision?).count
    number_of_offers = candidate_application_choices.select(&:offer?).count

    if candidate_application_choices.all?(&:rejected?)
      CandidateMailer.send(:application_rejected_all_rejected, application_choice).deliver_later
      add_audit_comment(application_choice)
    elsif number_of_pending_decisions.positive? && number_of_offers.zero?
      CandidateMailer.send(:application_rejected_awaiting_decisions_with_no_offers, application_choice).deliver_later
      add_audit_comment(application_choice)
    end
  end

private

  def add_audit_comment(application_choice)
    audit_comment =
      "New rejection email sent to candidate #{application_choice.application_form.candidate.email_address} for " +
      "#{application_choice.course_option.course.name_and_code} at #{application_choice.course_option.course.provider.name}."
    application_choice.application_form.update!(audit_comment: audit_comment)
  end
end
