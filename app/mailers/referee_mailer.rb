class RefereeMailer < ApplicationMailer
  def reference_request_email(reference)
    @application_form = reference.application_form
    @reference = reference
    @candidate_name = @application_form.full_name
    @unhashed_token = reference.refresh_feedback_token!

    notify_email(
      to: reference.email_address,
      subject: t('referee_mailer.reference_request.subject.initial', candidate_name: @candidate_name),
      reference: "#{HostingEnvironment.environment_name}-reference_request-#{reference.id}-#{SecureRandom.hex}",
      template_name: :reference_request_email,
      application_form_id: reference.application_form_id,
    )
  end

  def reference_request_chaser_email(application_form, reference)
    @application_form = application_form
    @reference = reference
    @candidate_name = application_form.full_name
    @token = reference.refresh_feedback_token!

    notify_email(
      to: reference.email_address,
      subject: t('referee_mailer.reference_request.subject.chaser', candidate_name: @candidate_name),
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
    @name = reference.name
    @candidate_name = reference.application_form.full_name
    @application_form = reference.application_form
    @token = reference.refresh_feedback_token!

    notify_email(
      to: reference.email_address,
      subject: t('referee_mailer.reference_request.subject.final', candidate_name: @candidate_name),
      application_form_id: reference.application_form_id,
    )
  end

private

  # rubocop:disable  Style/StringConcatenation
  def google_form_url_for(candidate_name, reference)
    # `to_query` replaces spaces with `+`, but a Google Form with a prefilled parameter
    # shows a `+` in the actual form, eg "Jane Doe" becomes "Jane+Doe", so we need to
    # switch them to %20 without stripping out a possible `+` in an email address
    t('referee_mailer.reference_request.google_form_url') +
      '?' +
      {
        t('referee_mailer.reference_request.email_entry') => reference.email_address,
        t('referee_mailer.reference_request.reference_id_entry') => reference.id,
      }.to_query +
      '&' +
      {
        t('referee_mailer.reference_request.candidate_name_entry') => candidate_name,
        t('referee_mailer.reference_request.referee_name_entry') => reference.name,
      }.to_query.gsub('+', '%20')
  end
  # rubocop:enable  Style/StringConcatenation
end
