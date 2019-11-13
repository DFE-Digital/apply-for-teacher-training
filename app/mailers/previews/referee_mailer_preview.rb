class RefereeMailerPreview < ActionMailer::Preview
  def reference_request_email
    application_form = FactoryBot.build(:completed_application_form)
    reference = application_form.references.first

    RefereeMailer.reference_request_email(application_form, reference)
  end
end
