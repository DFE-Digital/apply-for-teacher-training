class Covid19Mailer < ApplicationMailer
  def potential_delays(application_form)
    @application_form = application_form
    notify_email(
      to: @application_form.candidate.email_address,
      subject: 'There might be a delay in processing your teacher training application',
    )
  end
end
