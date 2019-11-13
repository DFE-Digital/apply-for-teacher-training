class RefereeMailer < ApplicationMailer
  def reference_request_email(application_form, reference)
    @reference = reference
    @candidate_name = "#{application_form.first_name} #{application_form.last_name}"
    @google_form_url = google_form_url_for(@candidate_name, @reference)

    view_mail(GENERIC_NOTIFY_TEMPLATE,
              to: reference.email_address,
              subject: t('reference_request.email.subject', candidate_name: @candidate_name))
  end

  def google_form_url_for(candidate_name, reference)
    t('reference_request.google_form_url') + '?' +
      {
        t('reference_request.email_entry') => reference.email_address,
        t('reference_request.reference_id_entry') => reference.id,
        t('reference_request.candidate_name_entry') => candidate_name,
        t('reference_request.referee_name_entry') => 'TODO: Referee name',
      }.to_query.gsub('+', '%20')
  end
end
