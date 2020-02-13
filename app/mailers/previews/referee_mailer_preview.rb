class RefereeMailerPreview < ActionMailer::Preview
  def reference_request_email
    application_form = FactoryBot.create(:application_form, first_name: 'Jane', last_name: 'Smith')
    reference = FactoryBot.create(:reference, application_form: application_form)

    RefereeMailer.reference_request_email(application_form, reference)
  end

  def reference_request_chaser_email
    application_form = FactoryBot.create(:application_form, first_name: 'Jane', last_name: 'Smith')
    reference = FactoryBot.create(:reference, application_form: application_form)

    RefereeMailer.reference_request_chaser_email(application_form, reference)
  end

  def reference_confirmation_email
    RefereeMailer.reference_confirmation_email(application_form, reference)
  end

private

  def application_form
    FactoryBot.build_stubbed(:application_form, first_name: 'Rachael', last_name: 'Harvey')
  end

  def reference
    FactoryBot.build_stubbed(:reference, application_form: application_form)
  end
end
