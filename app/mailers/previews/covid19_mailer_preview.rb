class Covid19MailerPreview < ActionMailer::Preview
  def potential_delays
    application_form = FactoryBot.build_stubbed(:application_form, first_name: 'Rick')

    Covid19Mailer.potential_delays(application_form)
  end
end
