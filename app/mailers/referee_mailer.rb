class RefereeMailer < ApplicationMailer
  def reference_request_email(application_form, reference)
    @application_form = application_form
    @reference = reference
    @candidate_name = "#{application_form.first_name} #{application_form.last_name}"

    if FeatureFlag.active?('reference_form')
      @reference_link = referee_interface_reference_feedback_url(token: reference.token)
      @decline_reference_link = referee_interface_decline_feedback_url(token: reference.token)
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
    @candidate_name = "#{application_form.first_name} #{application_form.last_name}"
    @google_form_url = google_form_url_for(@candidate_name, @reference)

    view_mail(GENERIC_NOTIFY_TEMPLATE,
              to: reference.email_address,
              subject: t('reference_request.subject.chaser', candidate_name: @candidate_name))
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
