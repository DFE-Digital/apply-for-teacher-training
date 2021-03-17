class CandidateMailerPreview < ActionMailer::Preview
  def application_submitted
    application_form = FactoryBot.build_stubbed(
      :completed_application_form,
      candidate: candidate,
      support_reference: 'ABCDEF',
    )

    CandidateMailer.application_submitted(application_form)
  end

  def application_submitted_apply_again
    application_form = FactoryBot.build_stubbed(
      :completed_application_form,
      candidate: candidate,
      support_reference: 'ABCDEF',
      application_choices: [FactoryBot.build_stubbed(:application_choice, :awaiting_provider_decision, course_option: course_option)],
    )

    CandidateMailer.application_submitted_apply_again(application_form)
  end

  def changed_offer
    application_form = application_form_with_course_choices([application_choice_with_offer, application_choice_with_offer])
    application_choice = FactoryBot.build_stubbed(
      :submitted_application_choice,
      course_option: course_option,
      application_form: application_form,
      offered_course_option: course_option,
      decline_by_default_at: 10.business_days.from_now,
    )

    CandidateMailer.changed_offer(application_choice)
  end

  def changed_unconditional_offer
    application_form = application_form_with_course_choices([application_choice_with_offer, application_choice_with_offer])
    application_choice = FactoryBot.build_stubbed(
      :submitted_application_choice,
      status: :offer,
      offer: { 'conditions' => [] },
      offered_at: Time.zone.now,
      offered_course_option: course_option,
      course_option: course_option,
      application_form: application_form,
      decline_by_default_at: 10.business_days.from_now,
    )

    CandidateMailer.changed_offer(application_choice)
  end

  def chase_reference
    CandidateMailer.chase_reference(reference)
  end

  def chase_reference_again
    CandidateMailer.chase_reference_again(reference)
  end

  def new_referee_request
    CandidateMailer.new_referee_request(reference, reason: :not_responded)
  end

  def new_referee_request_with_refused
    CandidateMailer.new_referee_request(reference, reason: :refused)
  end

  def new_referee_request_with_email_bounced
    CandidateMailer.new_referee_request(reference, reason: :email_bounced)
  end

  def new_interview
    application_choice = FactoryBot.build(:application_choice, :with_scheduled_interview)
    interview = application_choice.interviews.first
    CandidateMailer.new_interview(application_choice, interview)
  end

  def interview_updated
    application_choice = FactoryBot.build(:application_choice, :with_scheduled_interview)
    interview = application_choice.interviews.first
    CandidateMailer.interview_updated(application_choice, interview)
  end

  def interview_cancelled
    application_choice = FactoryBot.build(:application_choice, :with_scheduled_interview)
    interview = application_choice.interviews.first
    CandidateMailer.interview_cancelled(application_choice, interview, 'You contacted us to say you didn’t want to apply for this course any more.')
  end

  def chase_candidate_decision_with_one_offer
    application_form = application_form_with_course_choices([application_choice_with_offer])

    CandidateMailer.chase_candidate_decision(application_form)
  end

  def chase_candidate_decision_with_multiple_offers
    application_choices =
      [
        application_choice_with_offer,
        application_choice_with_offer,
        application_choice_with_offer,
      ]
    application_form = application_form_with_course_choices(application_choices)
    CandidateMailer.chase_candidate_decision(application_form)
  end

  def new_offer_single_offer
    application_choice = application_form.application_choices.build(
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
    course_option = FactoryBot.build_stubbed(:course_option, site: site)
    application_choice = application_form.application_choices.build(
      course_option: course_option,
      status: :offer,
      offer: { conditions: ['DBS check', 'Pass exams'] },
      offered_at: Time.zone.now,
      offered_course_option: course_option,
      decline_by_default_at: 10.business_days.from_now,
    )
    other_course_option = FactoryBot.build_stubbed(:course_option, site: site)
    application_form.application_choices.build(
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
    course_option = FactoryBot.build_stubbed(:course_option, site: site)
    application_choice = application_form.application_choices.build(
      course_option: course_option,
      status: :offer,
      offer: { conditions: ['DBS check', 'Pass exams'] },
      offered_at: Time.zone.now,
      offered_course_option: course_option,
      decline_by_default_at: 10.business_days.from_now,
    )
    other_course_option = FactoryBot.build_stubbed(:course_option, site: site)
    application_form.application_choices.build(
      course_option: other_course_option,
      status: :awaiting_provider_decision,
    )
    CandidateMailer.new_offer_decisions_pending(application_choice)
  end

  def new_unconditional_offer_decisions_pending
    course_option = FactoryBot.build_stubbed(:course_option, site: site)
    application_choice = application_form.application_choices.build(
      course_option: course_option,
      status: :offer,
      offer: { 'conditions' => [] },
      offered_at: Time.zone.now,
      offered_course_option: course_option,
      decline_by_default_at: 10.business_days.from_now,
    )
    other_course_option = FactoryBot.build_stubbed(:course_option, site: site)
    application_form.application_choices.build(
      course_option: other_course_option,
      status: :awaiting_provider_decision,
    )
    CandidateMailer.new_offer_decisions_pending(application_choice)
  end

  def application_rejected_all_applications_rejected
    application_choice = FactoryBot.build_stubbed(
      :application_choice,
      application_form: application_form,
      course_option: course_option,
      status: :rejected,
      structured_rejection_reasons: reasons_for_rejection_with_qualifications,
    )
    CandidateMailer.application_rejected_all_applications_rejected(application_choice)
  end

  def application_rejected_by_default_all_applications_rejected
    application_choice = FactoryBot.build_stubbed(
      :application_choice,
      :with_rejection_by_default_and_feedback,
      application_form: application_form,
      course_option: course_option,
    )
    CandidateMailer.application_rejected_all_applications_rejected(application_choice)
  end

  def application_rejected_one_offer_one_awaiting_decision
    application_form = FactoryBot.build_stubbed(
      :application_form,
      first_name: 'Tyrell',
      last_name: 'Wellick',
      candidate: candidate,
      application_choices: [
        FactoryBot.build_stubbed(
          :application_choice,
          application_form: application_form,
          course_option: course_option,
          status: :rejected,
          structured_rejection_reasons: reasons_for_rejection,
        ),
        FactoryBot.build_stubbed(
          :application_choice,
          :with_offer,
          application_form: application_form,
          reject_by_default_at: Time.zone.local(2021, 1, 13),
          course_option: course_option,
        ),
        FactoryBot.build_stubbed(
          :application_choice,
          application_form: application_form,
          reject_by_default_at: Time.zone.local(2021, 1, 17),
          status: :awaiting_provider_decision,
          course_option: course_option,
        ),
      ],
    )
    CandidateMailer.application_rejected_one_offer_one_awaiting_decision(application_form.application_choices.first)
  end

  def application_rejected_by_default_one_offer_one_awaiting_decision
    application_form = FactoryBot.build_stubbed(
      :application_form,
      first_name: 'Tyrell',
      last_name: 'Wellick',
      candidate: candidate,
      application_choices: [
        FactoryBot.build_stubbed(
          :application_choice,
          :with_rejection_by_default_and_feedback,
          application_form: application_form,
          course_option: course_option,
        ),
        FactoryBot.build_stubbed(
          :application_choice,
          :with_offer,
          application_form: application_form,
          decline_by_default_days: 10,
          course_option: course_option,
        ),
        FactoryBot.build_stubbed(
          :application_choice,
          application_form: application_form,
          reject_by_default_at: Time.zone.local(2021, 1, 17),
          status: :awaiting_provider_decision,
          course_option: course_option,
        ),
      ],
    )
    CandidateMailer.application_rejected_one_offer_one_awaiting_decision(application_form.application_choices.first)
  end

  def application_rejected_awaiting_decision_only
    application_form = FactoryBot.build_stubbed(
      :application_form,
      first_name: 'Tyrell',
      last_name: 'Wellick',
      candidate: candidate,
      application_choices: [
        FactoryBot.build_stubbed(
          :application_choice,
          application_form: application_form,
          course_option: course_option,
          status: :rejected,
          structured_rejection_reasons: reasons_for_rejection,
        ),
        FactoryBot.build_stubbed(
          :application_choice,
          status: :awaiting_provider_decision,
          application_form: application_form,
          reject_by_default_at: 3.days.from_now,
          course_option: course_option,
        ),
        FactoryBot.build_stubbed(
          :application_choice,
          application_form: application_form,
          reject_by_default_at: 2.days.from_now,
          status: :awaiting_provider_decision,
          course_option: course_option,
        ),
      ],
    )
    CandidateMailer.application_rejected_awaiting_decision_only(application_form.application_choices.first)
  end

  def application_rejected_by_default_awaiting_decision_only
    application_form = FactoryBot.build_stubbed(
      :application_form,
      first_name: 'Tyrell',
      last_name: 'Wellick',
      candidate: candidate,
      application_choices: [
        FactoryBot.build_stubbed(
          :application_choice,
          :with_rejection_by_default_and_feedback,
          application_form: application_form,
          course_option: course_option,
        ),
        FactoryBot.build_stubbed(
          :application_choice,
          status: :awaiting_provider_decision,
          application_form: application_form,
          reject_by_default_at: 3.days.from_now,
          course_option: course_option,
        ),
      ],
    )
    CandidateMailer.application_rejected_awaiting_decision_only(application_form.application_choices.first)
  end

  def application_rejected_offers_only
    application_form = FactoryBot.build_stubbed(
      :application_form,
      first_name: 'Tyrell',
      last_name: 'Wellick',
      candidate: candidate,
      application_choices: [
        FactoryBot.build_stubbed(
          :application_choice,
          application_form: application_form,
          course_option: course_option,
          status: :rejected,
          structured_rejection_reasons: reasons_for_rejection,
        ),
        FactoryBot.build_stubbed(
          :application_choice,
          :with_offer,
          application_form: application_form,
          decline_by_default_at: 3.days.from_now,
          course_option: course_option,
        ),
        FactoryBot.build_stubbed(
          :application_choice,
          :with_offer,
          application_form: application_form,
          decline_by_default_at: 2.days.from_now,
          course_option: course_option,
        ),
      ],
    )
    CandidateMailer.application_rejected_offers_only(application_form.application_choices.first)
  end

  def application_rejected_by_default_offers_only
    application_form = FactoryBot.build_stubbed(
      :application_form,
      first_name: 'Tyrell',
      last_name: 'Wellick',
      candidate: candidate,
      application_choices: [
        FactoryBot.build_stubbed(
          :application_choice,
          :with_rejection_by_default_and_feedback,
          application_form: application_form,
          course_option: course_option,
        ),
        FactoryBot.build_stubbed(
          :application_choice,
          :with_offer,
          application_form: application_form,
          decline_by_default_at: 3.days.from_now,
          course_option: course_option,
        ),
      ],
    )
    CandidateMailer.application_rejected_offers_only(application_form.application_choices.first)
  end

  def feedback_received_for_application_rejected_by_default
    application_choice =
      if FeatureFlag.active?(:structured_reasons_for_rejection_on_rbd)
        FactoryBot.build_stubbed(
          :application_choice,
          :with_structured_rejection_reasons,
          application_form: application_form,
          course_option: course_option,
        )
      else
        FactoryBot.build_stubbed(
          :application_choice,
          :with_rejection_by_default_and_feedback,
          application_form: application_form,
          course_option: course_option,
        )
      end

    CandidateMailer.feedback_received_for_application_rejected_by_default(application_choice)
  end

  def reference_received
    CandidateMailer.reference_received(reference)
  end

  def offer_accepted
    application_choice = FactoryBot.build_stubbed(:application_choice)
    CandidateMailer.offer_accepted(application_choice)
  end

  def declined_by_default_multiple_offers
    application_form = FactoryBot.build_stubbed(
      :application_form,
      first_name: 'Harry',
      application_choices: [
        FactoryBot.build_stubbed(:application_choice, status: 'declined', declined_by_default: true, course_option: course_option),
        FactoryBot.build_stubbed(:application_choice, status: 'declined', declined_by_default: true, course_option: course_option),
        FactoryBot.build_stubbed(:application_choice, status: 'awaiting_provider_decision', declined_by_default: false, course_option: course_option),
      ],
      candidate: candidate,
    )

    CandidateMailer.declined_by_default(application_form)
  end

  def declined_by_default_only_one_offer
    application_form = FactoryBot.build_stubbed(
      :application_form,
      first_name: 'Harry',
      application_choices: [
        FactoryBot.build_stubbed(:application_choice, status: 'declined', declined_by_default: true, course_option: course_option),
        FactoryBot.build_stubbed(:application_choice, status: 'awaiting_provider_decision', declined_by_default: false, course_option: course_option),
      ],
    )

    CandidateMailer.declined_by_default(application_form)
  end

  def declined_by_default_with_rejections
    application_form = FactoryBot.build_stubbed(
      :application_form,
      first_name: 'Harry',
      application_choices: [
        FactoryBot.build_stubbed(:application_choice, status: 'declined', declined_by_default: true, course_option: course_option),
        FactoryBot.build_stubbed(:application_choice, status: 'rejected', declined_by_default: false, course_option: course_option),
      ],
      candidate: candidate,
    )

    CandidateMailer.declined_by_default(application_form)
  end

  def declined_by_default_without_rejections
    application_form = FactoryBot.build_stubbed(
      :application_form,
      first_name: 'Harry',
      application_choices: [
        FactoryBot.build_stubbed(:application_choice, status: 'declined', declined_by_default: true, course_option: course_option),
        FactoryBot.build_stubbed(:application_choice, status: 'declined', declined_by_default: true, course_option: course_option),
      ],
      candidate: candidate,
    )

    CandidateMailer.declined_by_default(application_form)
  end

  def decline_last_application_choice
    application_form = FactoryBot.build_stubbed(
      :application_form,
      first_name: 'Harry',
      application_choices: [
        FactoryBot.build_stubbed(:application_choice, status: 'declined', course_option: course_option),
      ],
      candidate: candidate,
    )

    CandidateMailer.decline_last_application_choice(application_form.application_choices.first)
  end

  def withdraw_last_application_choice
    application_form = FactoryBot.build_stubbed(
      :application_form,
      first_name: 'Harry',
      application_choices: [
        FactoryBot.build_stubbed(:application_choice, status: 'withdrawn', course_option: course_option),
      ],
      candidate: candidate,
    )

    CandidateMailer.withdraw_last_application_choice(application_form)
  end

  def conditions_met
    CandidateMailer.conditions_met(application_choice_with_offer)
  end

  def conditions_not_met
    CandidateMailer.conditions_not_met(application_choice_with_offer)
  end

  def apply_again_call_to_action
    application_form = FactoryBot.build_stubbed(
      :application_form,
      first_name: 'Bob',
      candidate: candidate,
      application_choices: [
        FactoryBot.build_stubbed(:application_choice, status: 'rejected', course_option: course_option),
      ],
    )

    CandidateMailer.apply_again_call_to_action(application_form)
  end

  def deferred_offer
    application_form = FactoryBot.build_stubbed(
      :application_form,
      first_name: 'Harry',
      application_choices: [
        FactoryBot.build_stubbed(:application_choice, status: 'pending_conditions', course_option: course_option),
      ],
      candidate: candidate,
    )

    CandidateMailer.deferred_offer(application_form.application_choices.first)
  end

  def deferred_offer_reminder
    course_option = FactoryBot.build_stubbed(
      :course_option,
      course: FactoryBot.build_stubbed(
        :course,
        recruitment_cycle_year: RecruitmentCycle.previous_year,
      ),
    )

    application_choice = FactoryBot.build_stubbed(
      :application_choice,
      :with_deferred_offer,
      course_option: course_option,
      offered_course_option: course_option,
      application_form: application_form,
      decline_by_default_at: 10.business_days.from_now,
      offer_deferred_at: Time.zone.local(2020, 2, 3),
    )

    CandidateMailer.deferred_offer_reminder(application_choice)
  end

  def reinstated_offer_with_conditions
    application_choice = FactoryBot.build_stubbed(
      :application_choice,
      :with_accepted_offer,
      application_form: application_form,
      course_option: course_option,
      offer_deferred_at: Time.zone.local(2019, 10, 14),
    )
    CandidateMailer.reinstated_offer(application_choice)
  end

  def reinstated_offer_without_condidtions
    application_choice = FactoryBot.build_stubbed(
      :application_choice,
      :with_recruited,
      application_form: application_form,
      course_option: course_option,
      offer: { 'conditions' => [] },
      offer_deferred_at: Time.zone.local(2019, 10, 14),
    )
    CandidateMailer.reinstated_offer(application_choice)
  end

  def ucas_match_initial_email_duplicate_applications
    application_choice = FactoryBot.build_stubbed(
      :application_choice,
      application_form: application_form,
      course_option: course_option,
    )

    CandidateMailer.ucas_match_initial_email_duplicate_applications(application_choice)
  end

  def ucas_match_initial_email_multiple_acceptances
    candidate = FactoryBot.build_stubbed(:candidate, application_forms: [application_form])

    CandidateMailer.ucas_match_initial_email_multiple_acceptances(candidate)
  end

  def ucas_match_reminder_email_duplicate_applications
    application_choice = FactoryBot.build_stubbed(
      :application_choice,
      application_form: application_form,
      course_option: course_option,
    )
    ucas_match = FactoryBot.build_stubbed(
      :ucas_match,
      :need_to_send_reminder_emails,
      application_form: application_choice.application_form,
    )

    CandidateMailer.ucas_match_reminder_email_duplicate_applications(application_choice, ucas_match)
  end

  def ucas_match_reminder_email_multiple_acceptances
    ucas_match = FactoryBot.build_stubbed(
      :ucas_match,
      :need_to_send_reminder_emails,
    )

    CandidateMailer.ucas_match_reminder_email_multiple_acceptances(ucas_match)
  end

  def ucas_match_resolved_on_ucas_email
    application_choice = FactoryBot.build_stubbed(
      :application_choice,
      application_form: application_form,
      course_option: course_option,
    )

    CandidateMailer.ucas_match_resolved_on_ucas_email(application_choice)
  end

  def ucas_match_resolved_on_ucas_at_our_request_email
    application_choice = FactoryBot.build_stubbed(
      :application_choice,
      application_form: application_form,
      course_option: course_option,
    )

    CandidateMailer.ucas_match_resolved_on_ucas_at_our_request_email(application_choice)
  end

  def ucas_match_resolved_on_apply_email
    application_choice = FactoryBot.build_stubbed(
      :application_choice,
      application_form: application_form,
      course_option: course_option,
    )

    CandidateMailer.ucas_match_resolved_on_apply_email(application_choice)
  end

  def unconditional_offer_accepted
    application_choice = FactoryBot.build_stubbed(:application_choice)
    CandidateMailer.unconditional_offer_accepted(application_choice)
  end

private

  def candidate
    candidate = FactoryBot.build_stubbed(:candidate)

    # This is not great. It's necessary because some of our mail templates
    # generates and send a new magic link token to candidates.
    def candidate.update!(*)
      true
    end

    candidate
  end

  def application_form
    @application_form ||= FactoryBot.build_stubbed(:application_form, first_name: 'Gemma', candidate: candidate)
  end

  def reference
    FactoryBot.build_stubbed(:reference, application_form: application_form)
  end

  def application_form_with_course_choices(course_choices)
    FactoryBot.build_stubbed(
      :application_form,
      first_name: 'Tyrell',
      last_name: 'Wellick',
      application_choices: course_choices,
      candidate: candidate,
    )
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

  def application_choice_with_offer
    FactoryBot.build_stubbed(:application_choice, :with_offer,
                             course_option: course_option,
                             decline_by_default_at: Time.zone.now,
                             sent_to_provider_at: 1.day.ago)
  end

  def reasons_for_rejection
    {
      candidate_behaviour_y_n: 'Yes',
      candidate_behaviour_what_did_the_candidate_do: %w[other],
      candidate_behaviour_other: 'Bad language',
      candidate_behaviour_what_to_improve: 'Do not swear',
      quality_of_application_y_n: 'Yes',
      quality_of_application_which_parts_needed_improvement: %w[personal_statement subject_knowledge],
      quality_of_application_personal_statement_what_to_improve: 'Do not refer to yourself in the third person',
    }
  end

  def reasons_for_rejection_with_qualifications
    {
      qualifications_y_n: 'Yes',
      qualifications_other_details: 'Bad qualifications',
      qualifications_which_qualifications: %w[no_english_gcse other],
    }
  end
end
