class RefereeMailer < ApplicationMailer
  def reference_request_email(application_form, reference)
    @application_form = application_form
    @reference = reference
    @candidate_name = application_form.full_name

    if FeatureFlag.active?('reference_form')
      @reference_link = referee_interface_reference_feedback_url(token: reference.update_token!)
      @decline_reference_link = 'link_to_decline_the_reference' #TODO: implement the flow for Referee decline to give references
      template_name = :reference_request_email
    else
      @reference_link = google_form_url_for(@candidate_name, @reference)
      template_name = :reference_request_by_google_form_email
    end

    view_mail(GENERIC_NOTIFY_TEMPLATE,
              to: reference.email_address,
              subject: t('reference_request.subject.initial', candidate_name: @candidate_name),
              template_name: template_name)
  end

  def reference_request_chaser_email(application_form, reference)
    @application_form = application_form
    @reference = reference
    @candidate_name = application_form.full_name

    @reference_link = if FeatureFlag.active?('reference_form')
                        referee_interface_reference_feedback_url(token: reference.update_token!)
                      else
                        google_form_url_for(@candidate_name, @reference)
                      end

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
