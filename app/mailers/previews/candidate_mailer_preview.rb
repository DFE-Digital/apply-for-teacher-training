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

  def new_offer_single_offer
    course_option = FactoryBot.build_stubbed(:course_option)
    application_choice = application_form.application_choices.build(
      id: 123,
      course_option: course_option,
      status: :offer,
      offer: { conditions: ['DBS check', 'Pass exams'] },
      offered_at: Time.zone.now,
      offered_course_option: course_option,
      decline_by_default_at: 10.business_days.from_now,
    )
    CandidateMailer.new_offer_single_offer(application_choice)
  end

  def new_offer_multiple_offers
    course_option = FactoryBot.build_stubbed(:course_option)
    application_choice = application_form.application_choices.build(
      id: 123,
      course_option: course_option,
      status: :offer,
      offer: { conditions: ['DBS check', 'Pass exams'] },
      offered_at: Time.zone.now,
      offered_course_option: course_option,
      decline_by_default_at: 10.business_days.from_now,
    )
    other_course_option = FactoryBot.build_stubbed(:course_option)
    application_form.application_choices.build(
      id: 456,
      course_option: other_course_option,
      status: :offer,
      offer: { conditions: ['Get a degree'] },
      offered_at: Time.zone.now,
      offered_course_option: other_course_option,
      decline_by_default_at: 7.business_days.from_now,
    )
    CandidateMailer.new_offer_multiple_offers(application_choice)
  end

  def new_offer_decisions_pending
    course_option = FactoryBot.build_stubbed(:course_option)
    application_choice = application_form.application_choices.build(
      id: 123,
      course_option: course_option,
      status: :offer,
      offer: { conditions: ['DBS check', 'Pass exams'] },
      offered_at: Time.zone.now,
      offered_course_option: course_option,
      decline_by_default_at: 10.business_days.from_now,
    )
    other_course_option = FactoryBot.build_stubbed(:course_option)
    application_form.application_choices.build(
      id: 456,
      course_option: other_course_option,
      status: :awaiting_provider_decision,
    )
    CandidateMailer.new_offer_decisions_pending(application_choice)
  end

  def application_rejected_all_rejected
    provider = create(:provider)
    course = create(:course, provider: provider)
    application_form = create(:application_form, first_name: 'Tyrell', last_name: 'Wellick')
    course_option = create(:course_option, course: course)
    application_choice = create(:application_choice,
                                course_option: course_option,
                                application_form: application_form,
                                rejection_reason: rejection_reason)

    CandidateMailer.application_rejected_all_rejected(application_choice)
  end

  def application_rejected_awaiting_decisions
    provider = create(:provider)
    course = create(:course, provider: provider)
    application_form = create(:application_form, first_name: 'Tyrell', last_name: 'Wellick')
    course_option = create(:course_option, course: course)
    create(:application_choice, status: :awaiting_provider_decision, application_form: application_form)
    application_choice = create(:application_choice,
                                course_option: course_option,
                                application_form: application_form,
                                rejection_reason: rejection_reason)

    CandidateMailer.application_rejected_awaiting_decisions(application_choice)
  end

private

  def application_form
    @application_form ||= FactoryBot.build_stubbed(:application_form, first_name: 'Gemma')
  end

  def reference
    FactoryBot.build_stubbed(:reference, application_form: application_form)
  end
end
