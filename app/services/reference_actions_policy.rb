class ReferenceActionsPolicy
  def initialize(reference)
    @reference = reference
  end

  def can_send?
    reference.not_requested_yet? &&
      needs_more_references? &&
      valid_reference?
  end

  def can_resend?
    (reference.cancelled? || reference.cancelled_at_end_of_cycle?) &&
      needs_more_references? &&
      valid_reference?
  end

  def can_retry?
    reference.email_bounced? &&
      needs_more_references? &&
      valid_reference?
  end

private

  attr_reader :reference

  def needs_more_references?
    !reference.application_form.enough_references_have_been_provided?
  end

  def valid_reference?
    CandidateInterface::Reference::SubmitRefereeForm.new(
      submit: 'yes',
      reference_id: reference.id,
    ).valid?
  end
end
