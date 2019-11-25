class CandidateMailerPreview < ActionMailer::Preview
  def submit_application_email
    application_form = FactoryBot.build(
      :completed_application_form,
      support_reference: 'ABC-DEF',
    )

    CandidateMailer.submit_application_email(application_form)
  end

  def application_under_consideration
    application_choice = FactoryBot.build(:application_choice, :awaiting_provider_decision)

    CandidateMailer.application_under_consideration(
      FactoryBot.build(
        :completed_application_form,
        :without_application_choices,
        application_choices: [application_choice],
      ),
    )
  end
end
