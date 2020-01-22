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
        application_choices: [application_choice],
      ),
    )
  end

  def survey_email
    application_form = FactoryBot.build(:application_form, first_name: 'Gemma', last_name: 'Say')
    FactoryBot.build(:reference, application_form: application_form)

    CandidateMailer.survey_email(application_form)
  end
end
