class ReferenceActionsPolicy
  def initialize(reference)
    @reference = reference
  end

  def editable?
    reference.not_requested_yet? && needs_more_references?
  end

  def can_be_destroyed?
    (reference.not_requested_yet? || reference.feedback_provided?) && !reference.application_form.submitted?
  end

  def request_can_be_deleted?
    (reference.cancelled? || reference.feedback_refused? || reference.email_bounced?) && !reference.application_form.submitted?
  end

  def can_send_reminder?
    reference.feedback_requested? && reference.reminder_sent_at.nil?
  end

  def can_request?
    can_send? || can_resend? || can_retry?
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
    if FeatureFlag.active?(:reference_selection)
      true
    else
      !reference.application_form.enough_references_have_been_provided?
    end
  end

  def valid_reference?
    CandidateInterface::Reference::SubmitRefereeForm.new(
      submit: 'yes',
      reference_id: reference.id,
    ).valid?
  end
end
