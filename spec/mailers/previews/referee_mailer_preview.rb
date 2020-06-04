class RefereeMailerPreview < ActionMailer::Preview
  def reference_request_email
    RefereeMailer.reference_request_email(reference)
  end

  def reference_request_chaser_email
    provider = FactoryBot.build_stubbed(:provider)
    course = FactoryBot.build_stubbed(:course, provider: provider)
    site = FactoryBot.build_stubbed(:site)
    course_option = FactoryBot.build_stubbed(:course_option, course: course, site: site)
    application_form_with_application_choice = FactoryBot.build_stubbed(:application_form,
                                                                        first_name: 'Rachael',
                                                                        last_name: 'Harvey',
                                                                        application_choices: [FactoryBot.build_stubbed(:application_choice, course_option: course_option, application_form: application_form)])

    RefereeMailer.reference_request_chaser_email(application_form_with_application_choice, reference)
  end

  def reference_confirmation_email
    RefereeMailer.reference_confirmation_email(application_form, reference)
  end

  def reference_cancelled_email
    RefereeMailer.reference_cancelled_email(reference)
  end

private

  def application_form
    FactoryBot.build_stubbed(:application_form, first_name: 'Rachael', last_name: 'Harvey')
  end

  def reference
    reference = FactoryBot.build_stubbed(:reference, application_form: application_form)

    def reference.refresh_feedback_token!(*)
      123456
    end

    reference
  end
end
