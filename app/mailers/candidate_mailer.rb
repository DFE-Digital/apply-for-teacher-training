class CandidateMailer < ApplicationMailer
  def submit_application_email(application_form)
    @application_form = application_form

    view_mail(GENERIC_NOTIFY_TEMPLATE,
              to: application_form.candidate.email_address,
              subject: t('submit_application_success.email.subject'))
  end

  def application_under_consideration(application_form)
    @application = OpenStruct.new(
      candidate_name: application_form.first_name,
      choice_count: application_form.application_choices.count,
      rbd_date: application_form.application_choices.first.reject_by_default_at,
      rbd_days: application_form.application_choices.first.reject_by_default_days,
    )

    view_mail(GENERIC_NOTIFY_TEMPLATE,
              to: application_form.candidate.email_address,
              subject: t('application_under_consideration.email.subject'))
  end
end
