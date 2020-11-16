class ReferenceActionsPolicy
  def initialize(reference)
    @reference = reference
  end

  def can_send?
    reference.not_requested_yet? &&
      !reference.application_form.enough_references_have_been_provided? &&
      CandidateInterface::Reference::SubmitRefereeForm.new(
        submit: 'yes',
        reference_id: reference.id,
      ).valid?
  end

  def can_resend?
    (reference.cancelled? || reference.cancelled_at_end_of_cycle?) &&
      !reference.application_form.enough_references_have_been_provided? &&
      CandidateInterface::Reference::SubmitRefereeForm.new(
        submit: 'yes',
        reference_id: reference.id,
      ).valid?
  end

  def can_retry?
    reference.email_bounced? &&
      !reference.application_form.enough_references_have_been_provided? &&
      CandidateInterface::Reference::SubmitRefereeForm.new(
        submit: 'yes',
        reference_id: reference.id,
      ).valid?
  end

private

  attr_reader :reference
end
