class CandidateMailerPreview < ActionMailer::Preview
  def submit_application_email
    application_form = FactoryBot.build_stubbed(:application_form, support_reference: 'ABC-DEF')
    CandidateMailer.submit_application_email(application_form)
  end
end
