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

  def reference_chaser_email
    CandidateMailer.reference_chaser_email(application_form, reference)
  end

  def survey_email
    CandidateMailer.survey_email(application_form)
  end

  def survey_chaser_email
    CandidateMailer.survey_chaser_email(application_form)
  end

  def new_referee_request_with_not_responded
    CandidateMailer.new_referee_request(application_form, reference, reason: :not_responded)
  end

  def new_referee_request_with_refused
    CandidateMailer.new_referee_request(application_form, reference, reason: :refused)
  end

  def new_referee_request_with_email_bounced
    CandidateMailer.new_referee_request(application_form, reference, reason: :email_bounced)
  end

private

  def application_form
    FactoryBot.build_stubbed(:application_form, first_name: 'Gemma')
  end

  def reference
    FactoryBot.build_stubbed(:reference, application_form: application_form)
  end
end
