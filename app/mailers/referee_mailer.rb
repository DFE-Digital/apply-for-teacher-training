class RefereeMailer < ApplicationMailer
  def reference_request_email(application_form, reference)
    @application_form = application_form
    @reference = reference
    @candidate_name = application_form.full_name
    @unhashed_token = reference.refresh_feedback_token!

    view_mail(GENERIC_NOTIFY_TEMPLATE,
              to: reference.email_address,
              subject: t('reference_request.subject.initial', candidate_name: @candidate_name),
              reference: "#{HostingEnvironment.environment_name}-reference_request-#{reference.id}",
              template_name: :reference_request_email)
  end

  def reference_request_chaser_email(application_form, reference)
    @application_form = application_form
    @reference = reference
    @candidate_name = application_form.full_name
    @token = reference.refresh_feedback_token!

    view_mail(GENERIC_NOTIFY_TEMPLATE,
              to: reference.email_address,
              subject: t('reference_request.subject.chaser', candidate_name: @candidate_name))
  end

  def survey_email(application_form, reference)
    @name = reference.name
    @thank_you_message = t('survey_emails.thank_you.referee', candidate_name: application_form.full_name)

    view_mail(GENERIC_NOTIFY_TEMPLATE,
              to: reference.email_address,
              subject: t('survey_emails.subject.initial'),
              template_path: 'survey_emails',
              template_name: 'initial')
  end

  def survey_chaser_email(reference)
    @name = reference.name

    view_mail(GENERIC_NOTIFY_TEMPLATE,
              to: reference.email_address,
              subject: t('survey_emails.subject.chaser'),
              template_path: 'survey_emails',
              template_name: 'chaser')
  end

private

  def google_form_url_for(candidate_name, reference)
    # `to_query` replaces spaces with `+`, but a Google Form with a prefilled parameter
    # shows a `+` in the actual form, eg "Jane Doe" becomes "Jane+Doe", so we need to
    # switch them to %20 without stripping out a possible `+` in an email address
    t('reference_request.google_form_url') +
      '?' +
      {
        t('reference_request.email_entry') => reference.email_address,
        t('reference_request.reference_id_entry') => reference.id,
      }.to_query +
      '&' +
      {
        t('reference_request.candidate_name_entry') => candidate_name,
        t('reference_request.referee_name_entry') => reference.name,
      }.to_query.gsub('+', '%20')
  end
end
