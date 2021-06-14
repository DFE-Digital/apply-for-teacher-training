class RequestReference
  def call(reference)
    policy = ReferenceActionsPolicy.new(reference)
    raise "ApplicationReference##{reference.id} can't be requested" unless policy.can_request?

    RefereeMailer.reference_request_email(reference).deliver_later
    reference.update!(feedback_status: 'feedback_requested', requested_at: Time.zone.now)
    auto_approve_reference_in_sandbox(reference)
  end

private

  def auto_approve_reference_in_sandbox(reference)
    auto_approve_reference(reference) if HostingEnvironment.use_refbots? && email_address_is_a_bot?(reference)
  end

  def auto_approve_reference(reference)
    reference.update!(
      feedback_status: :feedback_provided,
      relationship_correction: '',
      safeguarding_concerns: '',
      safeguarding_concerns_status: :no_safeguarding_concerns_to_declare,
      feedback: 'Automatically approved.',
    )

    SubmitReference.new(
      reference: reference,
    ).save!
  end

  def email_address_is_a_bot?(reference)
    /^refbot(\d+)@example.com/ =~ reference.email_address
  end
end
