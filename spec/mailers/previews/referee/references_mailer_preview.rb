class Referee::ReferencesMailerPreview < ActionMailer::Preview
  def reference_request_email
    RefereeMailer.reference_request_email(reference(application_form_with_application_choice_with_accepted_offer))
  end

  def reference_request_chaser_email
    RefereeMailer.reference_request_chaser_email(application_form_with_application_choice_with_accepted_offer, reference(application_form_with_application_choice_with_accepted_offer))
  end

  def reference_request_chase_again_email
    RefereeMailer.reference_request_chase_again_email(reference(application_form_with_application_choice_with_accepted_offer))
  end

  def reference_confirmation_email
    RefereeMailer.reference_confirmation_email(application_form, reference(application_form))
  end

  def reference_cancelled_email
    RefereeMailer.reference_cancelled_email(reference(application_form))
  end

private

  def application_form
    FactoryBot.build_stubbed(:application_form, first_name: 'Rachael', last_name: 'Harvey')
  end

  def reference(application_form)
    reference = FactoryBot.build_stubbed(:reference, application_form:)

    def reference.refresh_feedback_token!(*)
      123456
    end

    reference
  end

  def application_form_with_application_choice_with_accepted_offer
    FactoryBot.build_stubbed(:application_form,
                             first_name: 'Rachael',
                             last_name: 'Harvey',
                             recruitment_cycle_year: ApplicationForm::OLD_REFERENCE_FLOW_CYCLE_YEAR + 1,
                             application_choices: [application_choice])
  end

  def application_choice
    FactoryBot.create(:application_choice, :accepted, course: FactoryBot.build_stubbed(:course))
  end
end
