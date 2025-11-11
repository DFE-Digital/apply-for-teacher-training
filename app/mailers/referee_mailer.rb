class RefereeMailer < ApplicationMailer
  def reference_request_email(reference)
    @application_form = reference.application_form
    @reference = reference
    @candidate_name = @application_form.full_name
    @candidate_first_name = @application_form.first_name
    @unhashed_token = reference.refresh_feedback_token!
    @referee_type = @reference.referee_type
    @provider_name = @application_form.application_choices.select(&:accepted_choice?).first.provider.name

    notify_email(
      to: reference.email_address,
      subject: t('referee_mailer.reference_request.subject', candidate_name: @candidate_name),
      reference: "#{HostingEnvironment.environment_name}-reference_request-#{reference.id}-#{SecureRandom.hex}",
      template_name: :reference_request_email,
      application_form_id: reference.application_form_id,
    )
  end

  def reference_request_chaser_email(application_form, reference)
    @application_form = application_form
    @reference = reference
    @candidate_name = @application_form.full_name
    @candidate_first_name = @application_form.first_name
    @unhashed_token = reference.refresh_feedback_token!
    @referee_type = @reference.referee_type
    @provider_name = @application_form.application_choices.select(&:accepted_choice?).first.provider.name

    notify_email(
      to: reference.email_address,
      subject: t('referee_mailer.reference_request.subject', candidate_name: @candidate_name),
      reference: "#{HostingEnvironment.environment_name}-reference_request-#{reference.id}-#{SecureRandom.hex}",
      template_name: :reference_request_email,
      application_form_id: reference.application_form_id,
    )
  end

  def reference_confirmation_email(application_form, reference)
    @name = reference.name
    @candidate_name = application_form.full_name

    notify_email(
      to: reference.email_address,
      subject: t('reference_confirmation_email.subject', candidate_name: @candidate_name),
      application_form_id: reference.application_form_id,
    )
  end

  def reference_cancelled_email(reference)
    @name = reference.name
    @candidate_name = reference.application_form.full_name

    notify_email(
      to: reference.email_address,
      subject: t('reference_cancelled_email.subject', candidate_name: @candidate_name),
      application_form_id: reference.application_form_id,
    )
  end

  def reference_request_chase_again_email(reference)
    @application_form = reference.application_form
    @reference = reference
    @candidate_name = @application_form.full_name
    @candidate_first_name = @application_form.first_name
    @unhashed_token = reference.refresh_feedback_token!
    @referee_type = @reference.referee_type
    @provider_name = @application_form.application_choices.select(&:accepted_choice?).first.provider.name

    notify_email(
      to: reference.email_address,
      subject: t('referee_mailer.reference_request.subject', candidate_name: @candidate_name),
      reference: "#{HostingEnvironment.environment_name}-reference_request-#{reference.id}-#{SecureRandom.hex}",
      application_form_id: reference.application_form_id,
    )
  end
end
