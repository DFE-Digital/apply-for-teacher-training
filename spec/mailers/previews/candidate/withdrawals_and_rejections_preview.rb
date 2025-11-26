class Candidate::WithdrawalsAndRejectionsPreview < ActionMailer::Preview
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

  def application_rejected_because_salaried_course_full
    application_form = FactoryBot.create(:application_form, first_nationality: 'British')
    application_choice = FactoryBot.build_stubbed(
      :application_choice,
      application_form:,
      course_option:,
      status: :rejected,
      structured_rejection_reasons: salaried_course_full_reasons,
      rejection_reasons_type: 'rejection_reasons',
    )
    CandidateMailer.application_rejected(application_choice)
  end

  def application_rejected_with_course_recommendation
    application_choice = FactoryBot.build_stubbed(
      :application_choice,
      status: :rejected,
      structured_rejection_reasons: {
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
        ],
      },
      rejection_reasons_type: :rejection_reasons,
    )
    CandidateMailer.application_rejected(application_choice, 'https://find-teacher-training-courses.service.gov.uk/results')
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

  def application_withdrawn_on_request_with_course_recommendation
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

    CandidateMailer.application_withdrawn_on_request(application_choice, 'https://find-teacher-training-courses.service.gov.uk/results')
  end

  def conditions_not_met
    application_choice = application_choice_with_offer.tap do |choice|
      choice.offer.conditions.first.status = :unmet
    end

    CandidateMailer.conditions_not_met(application_choice)
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

  def withdraw_last_application_choice_with_course_recommendation
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
    CandidateMailer.withdraw_last_application_choice(application_form, 'https://find-teacher-training-courses.service.gov.uk/results')
  end

private

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

  def reference_feedback_requested
    FactoryBot.build_stubbed(:reference, feedback_status: :feedback_requested)
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

  def salaried_course_full_reasons
    {
      selected_reasons: [
        { id: 'course_full', label: 'Course full', selected_reasons: [
          { id: 'salary_course_full', label: 'The salaried or apprenticeship route for this course is full' },
        ] },
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

  def application_choice_with_offer
    FactoryBot.build(:application_choice,
                     :offered,
                     application_form:,
                     course_option:,
                     sent_to_provider_at: 1.day.ago)
  end

  def candidate
    @candidate ||= FactoryBot.build_stubbed(:candidate)
  end

  def application_form
    @application_form ||= FactoryBot.build_stubbed(:application_form, first_name: 'Gemma', candidate:)
  end

  def course_option
    FactoryBot.build_stubbed(:course_option, course:, site:)
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
end
