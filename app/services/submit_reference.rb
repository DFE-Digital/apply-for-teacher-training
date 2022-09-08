class SubmitReference
  attr_reader :reference, :selected
  delegate :application_form, to: :reference

  def initialize(reference:, send_emails: true, selected: false)
    @reference = reference
    @send_emails = send_emails
    @selected = selected
  end

  def save!
    @reference.update!(
      feedback_status: :feedback_provided,
      feedback_provided_at: Time.zone.now,
      selected:,
    )

    if @send_emails
      CandidateMailer.reference_received(reference).deliver_later
      RefereeMailer.reference_confirmation_email(application_form, reference).deliver_later
      notify_provider_users
    end
  end

private

  def notify_provider_users
    return unless FeatureFlag.active?(:new_references_flow_providers)

    application_choices.each do |ac|
      ac.provider.provider_users.each do |pu|
        ProviderMailer.reference_received(
          provider_user: pu,
          application_choice: ac,
          reference: reference,
          course: course,
          ordinance: ordinance,
        ).deliver_later
      end
    end
  end

  # i.e 1st, 2nd, 3rd
  def ordinance
    @ordinance ||= reference.order_in_application_references.ordinalize
  end

  def course
    @course ||= reference.candidate.course_from_find
  end

  def application_choices
    @application_choices ||= reference.application_form.application_choices.pending_conditions
  end

  # Only progress the applications if the reference that is being submitted is
  # the 2nd referee, since there might be more than 2 references per form. We
  # do not want to send the references to the provider *again* when the 3rd or
  # 4th reference is submitted.
  def enough_references_have_been_provided?
    (
      application_form.application_references.feedback_provided + [@reference]
    ).uniq.count == ApplicationForm::REQUIRED_REFERENCE_SELECTIONS
  end

  def cancel_feedback_requested_references
    application_form.application_references.select(&:feedback_requested?).each do |reference|
      CancelReferee.new.call(reference:)
    end
  end
end
