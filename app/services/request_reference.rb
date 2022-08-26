class RequestReference
  include ActiveModel::Model
  attr_accessor :reference

  validate :reference_complete_information, if: :new_reference_flow?

  def send_request
    return unless valid?

    # In order to trigger the validation, this method
    # send request is used in the new references.
    # And for backwards compatibility with old references
    # I need to call the #call method
    call(@reference)
    true
  end

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

  def reference_complete_information
    errors.add(:reference, :incomplete_references) unless complete_reference?
  end

  def complete_reference?
    CandidateInterface::Reference::SubmitRefereeForm.new(
      submit: 'yes',
      reference_id: @reference.id,
    ).valid?
  end

  def new_reference_flow?
    @reference&.application_form&.show_new_reference_flow?
  end
end
