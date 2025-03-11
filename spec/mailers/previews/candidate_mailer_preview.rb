class CandidateMailerPreview < ActionMailer::Preview
  def application_choice_submitted
    application_form = FactoryBot.build_stubbed(
      :completed_application_form,
      candidate:,
      support_reference: 'ABCDEF',
      application_choices: [],
    )
    application_choice = FactoryBot.build_stubbed(:application_choice, :awaiting_provider_decision, course_option:, application_form:)

    CandidateMailer.application_choice_submitted(application_choice)
  end

  def changed_offer
    application_form = application_form_with_course_choices([application_choice_with_offer, application_choice_with_offer])
    application_choice = FactoryBot.build_stubbed(:application_choice, :awaiting_provider_decision,
                                                  :offered,
                                                  course_option:,
                                                  application_form:,
                                                  current_course_option: course_option)

    CandidateMailer.changed_offer(application_choice)
  end

  def change_course
    application_choice = FactoryBot.build_stubbed(:application_choice, :awaiting_provider_decision,
                                                  course_option:,
                                                  current_course_option: course_option)

    CandidateMailer.change_course(application_choice, application_choice.original_course_option)
  end

  def changed_unconditional_offer
    application_form = application_form_with_course_choices([application_choice_with_offer, application_choice_with_offer])
    application_choice = FactoryBot.build(:application_choice, :awaiting_provider_decision,
                                          :offered,
                                          offer: FactoryBot.build(:unconditional_offer),
                                          offered_at: Time.zone.now,
                                          current_course_option: course_option,
                                          course_option:,
                                          application_form:)

    CandidateMailer.changed_offer(application_choice)
  end

  def chase_reference
    CandidateMailer.chase_reference(reference_at_offer)
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
    application_choice = FactoryBot.build_stubbed(:application_choice, :interviewing)
    interview = FactoryBot.build_stubbed(:interview, provider: application_choice.current_course_option.course.provider)
    CandidateMailer.new_interview(application_choice, interview)
  end

  def interview_updated
    application_choice = FactoryBot.build_stubbed(:application_choice, :interviewing, application_form: application_form)
    interview = FactoryBot.build_stubbed(:interview, provider: application_choice.current_course_option.course.provider)
    previous_course = nil
    CandidateMailer.interview_updated(application_choice, interview, previous_course)
  end

  def interview_updated_course_changed
    application_choice = FactoryBot.build_stubbed(:application_choice, :interviewing, application_form: application_form)
    interview = FactoryBot.build_stubbed(:interview, provider: application_choice.current_course_option.course.provider)
    previous_course = FactoryBot.build_stubbed(:course)
    CandidateMailer.interview_updated(application_choice, interview, previous_course)
  end

  def interview_cancelled
    application_choice = FactoryBot.build_stubbed(:application_choice, :interviewing)
    interview = FactoryBot.build_stubbed(:interview, provider: application_choice.current_course_option.course.provider)
    CandidateMailer.interview_cancelled(application_choice, interview, 'You contacted us to say you didn’t want to apply for this course any more.')
  end

  def offer_10_day
    application_form_with_course_choices([application_choice_with_offer])

    CandidateMailer.offer_10_day(application_choice_with_offer)
  end

  def offer_20_day
    application_form_with_course_choices([application_choice_with_offer])

    CandidateMailer.offer_20_day(application_choice_with_offer)
  end

  def offer_30_day
    application_form_with_course_choices([application_choice_with_offer])

    CandidateMailer.offer_30_day(application_choice_with_offer)
  end

  def offer_40_day
    application_form_with_course_choices([application_choice_with_offer])

    CandidateMailer.offer_40_day(application_choice_with_offer)
  end

  def offer_50_day
    application_form_with_course_choices([application_choice_with_offer])

    CandidateMailer.offer_50_day(application_choice_with_offer)
  end

  def new_offer_made
    application_form_with_name = FactoryBot.build_stubbed(
      :application_form,
      first_name: 'Bob',
    )

    application_choice = FactoryBot.build_stubbed(
      :application_choice,
      application_form: application_form_with_name,
      course_option:,
      offer: FactoryBot.build(:offer, :with_unmet_conditions),
    )

    CandidateMailer.new_offer_made(application_choice)
  end

  def application_rejected(reasons = :rejection_reasons)
    application_choice = FactoryBot.build_stubbed(
      :application_choice,
      application_form:,
      course_option:,
      status: :rejected,
      structured_rejection_reasons: send(reasons),
      rejection_reasons_type: reasons.to_s,
    )
    CandidateMailer.application_rejected(application_choice)
  end

  def application_rejected_international_unverified
    application_choice = FactoryBot.create(
      :application_choice,
      status: :rejected,
      structured_rejection_reasons: international_qualifications_rejection_reasons,
      rejection_reasons_type: 'rejection_reasons',
    )

    FactoryBot.create(
      :degree_qualification,
      enic_reference: nil,
      institution_country: 'FR',
      application_form: application_choice.application_form,
    )
    CandidateMailer.application_rejected(application_choice)
  end

  def application_rejected_via_api
    application_rejected(:vendor_api_rejection_reasons)
  end

  def application_withdrawn_on_request
    application_form_with_provided_references = FactoryBot.build_stubbed(
      :application_form,
      first_name: 'Fred',
      application_references: [
        FactoryBot.build_stubbed(:reference, feedback_status: :feedback_requested),
        FactoryBot.build_stubbed(:reference, feedback_status: :feedback_requested),
      ],
    )

    application_choice = FactoryBot.build_stubbed(
      :application_choice,
      application_form: application_form_with_provided_references,
      course_option:,
      status: :withdrawn,
      withdrawn_at: Time.zone.now,
    )

    CandidateMailer.application_withdrawn_on_request(application_choice)
  end

  def feedback_received_for_application_rejected_by_default
    application_choice =
      FactoryBot.build(
        :application_choice,
        :with_structured_rejection_reasons,
        application_form:,
        course_option:,
      )
    show_apply_again_guidance = false

    CandidateMailer.feedback_received_for_application_rejected_by_default(application_choice, show_apply_again_guidance)
  end

  def feedback_received_for_application_rejected_by_default_apply_again
    application_choice =
      FactoryBot.build(
        :application_choice,
        :with_structured_rejection_reasons,
        application_form:,
        course_option:,
      )
    show_apply_again_guidance = true

    CandidateMailer.feedback_received_for_application_rejected_by_default(application_choice, show_apply_again_guidance)
  end

  def reference_received
    CandidateMailer.reference_received(reference)
  end

  def reference_received_after_recruitment
    reference_at_offer.application_form.application_choices.first.update!(status: :recruited)
    CandidateMailer.reference_received(reference)
  end

  def two_references_received
    application_form_with_provided_references = FactoryBot.build_stubbed(
      :application_form,
      application_references: [
        FactoryBot.build_stubbed(:reference, feedback_status: :feedback_provided),
        FactoryBot.build_stubbed(:reference, feedback_status: :feedback_provided),
      ],
    )

    new_reference = FactoryBot.build_stubbed(:reference, application_form: application_form_with_provided_references)

    CandidateMailer.reference_received(new_reference)
  end

  def three_or_more_references_received
    application_form_with_provided_references = FactoryBot.build_stubbed(
      :application_form,
      application_references: [
        FactoryBot.build_stubbed(:reference, feedback_status: :feedback_provided),
        FactoryBot.build_stubbed(:reference, feedback_status: :feedback_provided),
        FactoryBot.build_stubbed(:reference, feedback_status: :feedback_provided),
      ],
    )

    new_reference = FactoryBot.build_stubbed(:reference, application_form: application_form_with_provided_references)

    CandidateMailer.reference_received(new_reference)
  end

  def reference_received_after_selection
    application_form_with_selected_references = FactoryBot.build_stubbed(
      :application_form,
      application_references: [
        FactoryBot.build_stubbed(:reference, selected: true, feedback_status: :feedback_provided),
        FactoryBot.build_stubbed(:reference, selected: true, feedback_status: :feedback_provided),
      ],
    )

    new_reference = FactoryBot.build_stubbed(:reference, application_form: application_form_with_selected_references)

    CandidateMailer.reference_received(new_reference)
  end

  def offer_withdrawn
    candidate = FactoryBot.build_stubbed(:candidate)
    application_choice = FactoryBot.build_stubbed(
      :application_choice,
      offer_withdrawal_reason: Faker::Lorem.sentence,
      application_form: FactoryBot.build_stubbed(:application_form, first_name: 'Geoff', candidate:),
    )
    CandidateMailer.offer_withdrawn(application_choice)
  end

  def offer_accepted
    application_form_with_name = FactoryBot.build_stubbed(
      :application_form,
      first_name: 'Bob',
    )

    application_choice = FactoryBot.build_stubbed(:application_choice, application_form: application_form_with_name)
    CandidateMailer.offer_accepted(application_choice)
  end

  def decline_last_application_choice
    application_form = FactoryBot.build_stubbed(
      :application_form,
      first_name: 'Harry',
      application_choices: [
        FactoryBot.build_stubbed(:application_choice, status: 'declined', course_option:),
      ],
      candidate:,
    )

    CandidateMailer.decline_last_application_choice(application_form.application_choices.first)
  end

  def withdraw_last_application_choice
    application_form = FactoryBot.build_stubbed(
      :application_form,
      first_name: 'Harry',
      application_choices: [
        FactoryBot.build_stubbed(:application_choice, status: 'withdrawn', course_option:),
      ],
      application_references: [
        reference_feedback_requested,
        reference_feedback_requested,
      ],
      candidate:,
    )
    CandidateMailer.withdraw_last_application_choice(application_form)
  end

  def conditions_statuses_changed
    met_conditions = FactoryBot.build_stubbed_list(:text_condition, 1)
    pending_conditions = FactoryBot.build_stubbed_list(:text_condition, 2)
    previously_met_conditions = FactoryBot.build_stubbed_list(:text_condition, 1)
    CandidateMailer.conditions_statuses_changed(application_choice_with_offer, met_conditions, pending_conditions, previously_met_conditions)
  end

  def conditions_met
    CandidateMailer.conditions_met(application_choice_with_offer)
  end

  def conditions_met_with_pending_ske_conditions
    application_choice = application_choice_pending_conditions.tap do |choice|
      choice.offer.conditions.first.status = :met
      choice.offer.ske_conditions = [FactoryBot.build_stubbed(:ske_condition, status: :pending)]
      choice.status = :recruited
      choice.current_course_option.provider.provider_type = :scitt
      choice.current_course_option.course.start_date = 1.month.from_now
    end

    CandidateMailer.conditions_met(application_choice)
  end

  def conditions_not_met
    application_choice = application_choice_with_offer.tap do |choice|
      choice.offer.conditions.first.status = :unmet
    end

    CandidateMailer.conditions_not_met(application_choice)
  end

  def deferred_offer
    application_form = FactoryBot.build_stubbed(
      :application_form,
      first_name: 'Harry',
      application_choices: [
        FactoryBot.build_stubbed(:application_choice, status: 'pending_conditions', course_option:),
      ],
      candidate:,
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

    application_choice = FactoryBot.build(
      :application_choice,
      :offer_deferred,
      course_option:,
      current_course_option: course_option,
      application_form:,
      offer_deferred_at: Time.zone.local(2020, 2, 3),
    )

    CandidateMailer.deferred_offer_reminder(application_choice)
  end

  def eoc_first_deadline_reminder
    application_form = FactoryBot.build(
      :application_form,
      first_name: 'Tester',
    )

    CandidateMailer.eoc_first_deadline_reminder(application_form)
  end

  def eoc_second_deadline_reminder
    application_form = FactoryBot.build(
      :application_form,
      first_name: 'Tester',
    )

    CandidateMailer.eoc_second_deadline_reminder(application_form)
  end

  def eoc_first_deadline_reminder_with_no_first_name
    application_form = FactoryBot.build(
      :application_form,
      first_name: nil,
    )

    CandidateMailer.eoc_first_deadline_reminder(application_form)
  end

  def eoc_second_deadline_reminder_with_no_first_name
    application_form = FactoryBot.build(
      :application_form,
      first_name: nil,
    )

    CandidateMailer.eoc_second_deadline_reminder(application_form)
  end

  def application_deadline_has_passed
    application_form = FactoryBot.build(
      :application_form,
      first_name: 'Rocket',
    )

    CandidateMailer.application_deadline_has_passed(application_form)
  end

  def respond_to_offer_before_deadline
    application_form = FactoryBot.build(:application_form, first_name: 'Bart')

    CandidateMailer.respond_to_offer_before_deadline(application_form)
  end

  def reject_by_default_explainer
    application_form = FactoryBot.build(:application_form, first_name: 'Lisa')

    CandidateMailer.reject_by_default_explainer(application_form)
  end

  def new_cycle_has_started
    application_form = FactoryBot.build(:completed_application_form, first_name: 'Tester')

    CandidateMailer.new_cycle_has_started(application_form)
  end

  def find_has_opened
    application_form = FactoryBot.build(:application_form, first_name: 'Tester', submitted_at: nil)

    CandidateMailer.find_has_opened(application_form)
  end

  def duplicate_match_email
    application_form = FactoryBot.build(:application_form, first_name: 'Tester', submitted_at: Time.zone.now)

    CandidateMailer.duplicate_match_email(application_form)
  end

  def find_has_opened_no_name
    application_form = FactoryBot.build(:application_form, first_name: nil, submitted_at: nil)

    CandidateMailer.find_has_opened(application_form)
  end

  def reinstated_offer_with_conditions
    application_choice = FactoryBot.build_stubbed(
      :application_choice,
      :accepted,
      application_form:,
      course_option:,
      offer_deferred_at: Time.zone.local(2019, 10, 14),
    )
    CandidateMailer.reinstated_offer(application_choice)
  end

  def reinstated_offer_without_conditions
    application_choice = FactoryBot.build(
      :application_choice,
      :recruited,
      application_form:,
      course_option:,
      offer: FactoryBot.build(:unconditional_offer),
      offer_deferred_at: Time.zone.local(2019, 10, 14),
    )
    CandidateMailer.reinstated_offer(application_choice)
  end

  def unconditional_offer_accepted
    application_form_with_name = FactoryBot.build_stubbed(
      :application_form,
      first_name: 'Bob',
    )
    application_choice = FactoryBot.build_stubbed(:application_choice, application_form: application_form_with_name)
    CandidateMailer.unconditional_offer_accepted(application_choice)
  end

  def nudge_unsubmitted
    application_form = FactoryBot.create(:completed_application_form)
    CandidateMailer.nudge_unsubmitted(application_form)
  end

  def nudge_unsubmitted_with_incomplete_courses
    application_form = FactoryBot.create(:completed_application_form)
    CandidateMailer.nudge_unsubmitted_with_incomplete_courses(application_form)
  end

  def nudge_unsubmitted_with_incomplete_personal_statement
    application_form = FactoryBot.create(:completed_application_form)
    CandidateMailer.nudge_unsubmitted_with_incomplete_personal_statement(application_form)
  end

  def nudge_unsubmitted_with_incomplete_references
    application_form = FactoryBot.build_stubbed(
      :application_form,
      :minimum_info,
      first_name: 'Fred',
    )
    CandidateMailer.nudge_unsubmitted_with_incomplete_references(application_form)
  end

  def apply_to_another_course_after_30_working_days
    application_form = FactoryBot.create(
      :application_form,
      :minimum_info,
      first_name: 'Fred',
      application_choices: [
        FactoryBot.create(
          :application_choice,
          :inactive,
        ),
      ],
    )

    CandidateMailer.apply_to_another_course_after_30_working_days(application_form)
  end

  def apply_to_multiple_courses_after_30_working_days
    application_form = FactoryBot.create(
      :application_form,
      :minimum_info,
      first_name: 'Fred',
      application_choices: FactoryBot.create_list(
        :application_choice,
        2,
        :inactive,
      ),
    )

    CandidateMailer.apply_to_multiple_courses_after_30_working_days(application_form)
  end

  def course_invite
    application_form = FactoryBot.create(
      :application_form,
      :minimum_info,
      first_name: 'Fred',
    )
    candidate = FactoryBot.create(:candidate, application_forms: [application_form])
    pool_invite = FactoryBot.create(:pool_invite, candidate:)

    CandidateMailer.course_invite(pool_invite)
  end

private

  def candidate
    @candidate ||= FactoryBot.build_stubbed(:candidate)
  end

  def application_form
    @application_form ||= FactoryBot.build_stubbed(:application_form, first_name: 'Gemma', candidate:)
  end

  def reference
    FactoryBot.build_stubbed(:reference, application_form:)
  end

  def reference_at_offer
    @application_form = FactoryBot.create(:application_form, :minimum_info, application_choices: [application_choice_pending_conditions])
    FactoryBot.create(:reference, application_form: @application_form)
  end

  def reference_feedback_requested
    FactoryBot.build_stubbed(:reference, feedback_status: :feedback_requested)
  end

  def application_form_with_course_choices(course_choices)
    FactoryBot.build_stubbed(
      :application_form,
      first_name: 'Tyrell',
      last_name: 'Wellick',
      application_choices: course_choices,
      candidate:,
    )
  end

  def provider
    FactoryBot.build_stubbed(:provider)
  end

  def course
    FactoryBot.build_stubbed(:course, provider:)
  end

  def site
    @site ||= FactoryBot.build_stubbed(:site, code: '-', name: 'Main site')
  end

  def course_option
    FactoryBot.build_stubbed(:course_option, course:, site:)
  end

  def application_choice_pending_conditions
    provider = FactoryBot.build(:provider, name: 'Brighthurst Technical College')
    course = FactoryBot.build(:course, name: 'Applied Science (Psychology)', code: '3TT5', provider: provider)
    course_option = FactoryBot.build(:course_option, course: course)

    FactoryBot.build(:application_choice,
                     :pending_conditions,
                     application_form:,
                     course_option: course_option,
                     sent_to_provider_at: 1.day.ago)
  end

  def application_choice_with_offer
    FactoryBot.build(:application_choice,
                     :offered,
                     application_form:,
                     course_option:,
                     sent_to_provider_at: 1.day.ago)
  end

  def international_qualifications_rejection_reasons
    {
      selected_reasons: [
        { id: 'qualifications', label: 'Qualifications', selected_reasons: [
          {
            id: 'unverified_qualifications',
            label: 'Could not verify qualifications',
            details: { id: 'unverified_qualifications_details', text: 'We could not verify your degree.' },
          },
          {
            id: 'unverified_equivalency_qualifications',
            label: 'Could not verify equivalency of qualifications',
            details: { id: 'unverified_equivalency_qualifications_details', text: 'We could verify the equivalency of your GCSEs because they are not from the UK.' },
          },
        ] },
      ],
    }
  end

  def rejection_reasons
    {
      selected_reasons: [
        { id: 'teaching_knowledge', label: 'Teaching knowledge, ability and interview performance',
          selected_reasons: [
            { id: 'subject_knowledge', label: 'Subject knowledge',
              details: {
                id: 'subject_knowledge_details',
                text: 'You did need to improve your knowledge of the subject',
              } },
            { id: 'teaching_knowledge_other', label: 'Other',
              details: {
                id: 'teaching_knowledge_other_details',
                text: 'You did not demonstrate enough knowledge about teaching in the UK.',
              } },
          ] },
        { id: 'qualifications', label: 'Qualifications', selected_reasons: [
          { id: 'no_maths_gcse', label: 'No maths GCSE at minimum grade 4 or C, or equivalent' },
          { id: 'no_english_gcse', label: 'No English GCSE at minimum grade 4 or C, or equivalent' },
          { id: 'no_science_gcse', label: 'No science GCSE at minimum grade 4 or C, or equivalent' },
          { id: 'no_degree', label: 'No bachelor’s degree or equivalent' },
          {
            id: 'unsuitable_degree',
            label: 'Degree grade does not meet course requirements',
            details: { id: 'unsuitable_degree_details', text: 'Your degree does not meet course requirements.' },
          },
          {
            id: 'unsuitable_degree_subject',
            label: 'Degree subject does not meet course requirements',
            details: { id: 'unsuitable_degree_subject_details', text: 'Your degree subject does not match.' },
          },
          {
            id: 'unverified_qualifications',
            label: 'Could not verify qualifications',
            details: { id: 'unverified_qualifications_details', text: 'We could find no record of your GCSEs.' },
          },
          {
            id: 'unverified_equivalency_qualifications',
            label: 'Could not verify equivalency of qualifications',
            details: { id: 'unverified_equivalency_qualifications_details', text: 'We could verify the equivalency of your qualifications.' },
          },
          {
            id: 'already_qualified',
            label: 'Already has a teaching qualification',
            details: { id: 'already_qualified_details', text: 'You are already a qualified teacher.' },
          },
          {
            id: 'qualifications_other',
            label: 'Other',
            details: {
              id: 'qualifications_other_details', text: 'Your qualifications are not appropriate for this course.'
            },
          },
        ] },
        {
          id: 'communication_and_scheduling',
          label: 'Communication, interview attendance and scheduling',
          selected_reasons: [
            {
              id: 'english_below_standard',
              label: 'English language ability below expected standard',
              details: { id: 'english_below_standard_details', text: 'Consider taking steps to improve your spoken English.' },
            },
            {
              id: 'did_not_attend_interview',
              label: 'Did not attend interview',
              details: { id: 'did_not_attend_interview_details', text: 'You failed to show up for the interview we confirmed with you' },
            },
            { id: 'communication_and_scheduling_other',
              label: 'Other',
              details: { id: 'communication_and_scheduling_other_details', text: 'Communication issues' } },
          ],
        },
        { id: 'personal_statement',
          label: 'Personal statement',
          selected_reasons: [
            { id: 'quality_of_writing',
              label: 'Quality of writing',
              details: { id: 'quality_of_writing_details', text: 'We do not accept applications written in Old Norse.' } },
          ] },
        { id: 'course_full', label: 'Course full' },
        {
          id: 'school_placement',
          label: 'School placement',
          selected_reasons: [
            {
              id: 'no_placements',
              label: 'No available placements',
              details: { id: 'no_placements_details', text: 'We filled all our placements.' },
            },
            {
              id: 'no_suitable_placements',
              label: 'No placements that are suitable',
              details: { id: 'no_suitable_placements_details', text: 'We do not have a suitable place for you.' },
            },
            {
              id: 'placements_other',
              label: 'Other',
              details: { id: 'no_placements_details', text: 'We have funding issues.' },
            },
          ],
        },
        { id: 'other', label: 'Other', details: { id: 'other_details', text: 'So many other things were wrong...' } },
        { id: 'safeguarding', label: 'Safeguarding', details: { id: 'safeguarding_details', text: 'We have safeguarding concerns' } },
        { id: 'visa_sponsorship', label: 'Visa sponsorship', details: { id: 'visa_sponsorship_details', text: 'We cannot sponsor your visa' } },
      ],
    }
  end

  def vendor_api_rejection_reasons
    {
      selected_reasons: [
        { id: 'qualifications', label: 'Qualifications', details: { id: 'qualifications_details', text: 'We could not find any record of your qualifications' } },
        {
          id: 'personal_statement', label: 'Personal statement',
          details: {
            id: 'personal_statement_details',
            text: 'We do not accept applications written in Old Norse.',
          }
        },
        {
          id: 'references', label: 'References',
          details: {
            id: 'references_details',
            text: 'We do not accept references from close family members, such as your mum.',
          }
        },
        { id: 'other', label: 'Other', details: { id: 'other_details', text: 'So many other things were wrong...' } },
      ],
    }
  end

  def qualifications_other
    {
      id: 'qualifications_other',
      label: 'Other',
      details: { id: 'qualifications_other_details', text: 'Some other things were sub-optimal...' },
    }
  end
end
