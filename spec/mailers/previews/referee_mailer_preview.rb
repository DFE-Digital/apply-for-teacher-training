class RefereeMailerPreview < ActionMailer::Preview
  def reference_request_email
    RefereeMailer.reference_request_email(reference(application_form_with_application_choice))
  end

  def reference_request_chaser_email
    RefereeMailer.reference_request_chaser_email(application_form_with_application_choice, reference(application_form_with_application_choice))
  end

  def reference_confirmation_email
    RefereeMailer.reference_confirmation_email(application_form, reference(application_form))
  end

  def reference_cancelled_email
    RefereeMailer.reference_cancelled_email(reference(application_form))
  end

  def reference_request_chase_again_email
    RefereeMailer.reference_request_chase_again_email(reference(application_form_with_application_choice))
  end

private

  def application_form
    FactoryBot.build_stubbed(:application_form, first_name: 'Rachael', last_name: 'Harvey')
  end

  def reference(application_form)
    reference = FactoryBot.build_stubbed(:reference, application_form: application_form)

    def reference.refresh_feedback_token!(*)
      123456
    end

    reference
  end

  def provider
    FactoryBot.build_stubbed(:provider)
  end

  def course
    FactoryBot.build_stubbed(:course, provider: provider)
  end

  def site
    @site ||= FactoryBot.build_stubbed(:site, code: '-', name: 'Main site')
  end

  def course_option
    FactoryBot.build_stubbed(:course_option, course: course, site: site)
  end

  def application_form_with_application_choice
    FactoryBot.build_stubbed(:application_form,
                             first_name: 'Rachael',
                             last_name: 'Harvey',
                             application_choices: [application_choice])
  end

  def application_choice
    FactoryBot.build_stubbed(:application_choice, course_option: course_option, application_form: application_form)
  end
end
