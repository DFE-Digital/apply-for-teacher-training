class RefereeMailerPreview < ActionMailer::Preview
  def reference_request_email
    application_form = FactoryBot.create(:application_form)
    reference = FactoryBot.create(:reference, application_form: application_form)

    RefereeMailer.reference_request_email(application_form, reference)
  end

  def reference_request_chaser_email
    application_form = FactoryBot.create(:application_form)
    reference = FactoryBot.create(:reference, application_form: application_form)

    RefereeMailer.reference_request_chaser_email(application_form, reference)
  end

  def survey_email
    application_form = FactoryBot.build_stubbed(:application_form, first_name: 'Rachael')
    reference = FactoryBot.build_stubbed(:reference, application_form: application_form)

    RefereeMailer.survey_email(application_form, reference)
  end

  def survey_chaser_email
    application_form = FactoryBot.build_stubbed(:application_form, first_name: 'Rachael')
    reference = FactoryBot.build_stubbed(:reference, application_form: application_form)

    RefereeMailer.survey_chaser_email(reference)
  end
end
