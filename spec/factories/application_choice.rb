FactoryBot.define do
  factory :application_choice do
    application_form { association(:application_form, **form_options) }

    # Beware that passing in a `course` (implicitly bypassing `course_option`) will
    # cause problems with any attributes in this factory which rely on the
    # `course_option` being present, as it will not exist until after the
    # record is saved.
    transient do
      candidate { nil }
      course { nil }
      recruitment_cycle_year { nil }
      form_options {
        {
          recruitment_cycle_year:,
          candidate:,
        }.compact_blank
      }
    end

    course_option do
      course&.course_options&.first || association(
        :course_option,
        :open,
        recruitment_cycle_year: recruitment_cycle_year || application_form.recruitment_cycle_year,
      )
    end

    school_placement_auto_selected { false }

    current_recruitment_cycle_year { recruitment_cycle_year || course_option.course.recruitment_cycle_year }
    personal_statement { Faker::Lorem.paragraph_by_chars(number: 50) }
    original_course_option { course_option }
    current_course_option { course_option }
    provider_ids { provider_ids_for_access }

    status do
      if application_form&.submitted?
        ApplicationStateChange::STATES_VISIBLE_TO_PROVIDER.sample
      else
        'unsubmitted'
      end
    end

    sent_to_provider_at { (created_at || Time.zone.now) + 1.second if submitted? }
    withdrawn_at { (sent_to_provider_at || Time.zone.now) + 1.second if withdrawn? }

    trait :with_personal_statement do
      personal_statement { Faker::Lorem.paragraph_by_chars(number: 500) }
    end

    trait :previous_year do
      course_option factory: %i[course_option previous_year]

      transient do
        recruitment_cycle_year { CycleTimetableHelper.previous_year }
      end
    end

    trait :previous_year_but_still_available do
      previous_year
      course_option factory: %i[course_option previous_year_but_still_available]
    end

    trait :with_course_uuid do
      course_option do
        association(
          :course_option,
          :open,
          :with_course_uuid,
          recruitment_cycle_year: application_form.recruitment_cycle_year,
        )
      end
    end

    trait :with_completed_application_form do
      application_form do
        association(:application_form, :completed, :with_degree_and_gcses, **form_options)
      end
    end

    trait :with_submitted_application_form do
      application_form do
        association(:application_form, :submitted, **form_options)
      end
    end

    trait :unsubmitted do
      status { :unsubmitted }
    end

    trait :application_not_sent do
      status { 'application_not_sent' }
      rejected_at { (created_at || Time.zone.now) + 1.second }
      rejection_reason { 'Recruitment cycle closed.' }
    end

    trait :offered do
      with_completed_application_form
      offer { association(:offer, application_choice: instance) }

      status { :offer }

      created_at { (application_form&.created_at || Time.zone.now) + 1.second }
      sent_to_provider_at { (created_at || Time.zone.now) + 1.second }
      offered_at { (sent_to_provider_at || Time.zone.now) + 1.second }
    end

    # aliased name to match the status
    trait :offer do
      offered
    end

    trait :course_changed do
      current_course_option do
        other_courses = course_option.provider.courses
          .in_cycle(course_option.course.recruitment_cycle_year)
          .with_course_options
          .where(accredited_provider: course_option.accredited_provider)

        (other_courses - [course_option.course]).sample&.course_options&.first || build(:course_option)
      end

      current_recruitment_cycle_year { current_course_option.course.recruitment_cycle_year }

      course_changed_at { (offered_at || Time.zone.now) + 1.second }

      # This needs changing after providers are changed
      after(:build) do |application_choice, _evaluator|
        application_choice.provider_ids = application_choice.provider_ids_for_access
      end
    end

    trait :course_changed_before_offer do
      offered
      course_changed
    end

    trait :course_changed_after_offer do
      offered
      course_changed
      course_changed_at { nil }
      offer_changed_at { (offered_at || Time.zone.now) + 1.second }
    end

    trait :accepted do
      offered

      status { :pending_conditions }

      accepted_at { (offered_at || Time.zone.now) + 1.second }
    end
    trait(:pending_conditions) { accepted }

    trait :accepted_no_conditions do
      recruited
      offer { association(:unconditional_offer, application_choice: instance) }
    end

    trait :recruited do
      accepted

      status { :recruited }

      recruited_at { (accepted_at || Time.zone.now) + 1.second }
    end

    trait :awaiting_provider_decision do
      with_submitted_application_form

      status { :awaiting_provider_decision }

      reject_by_default_days { 40 }
      reject_by_default_at { reject_by_default_days.business_days.from_now }
    end

    trait :interviewing do
      awaiting_provider_decision

      status { :interviewing }

      interviews do
        [build(:interview, provider: current_course_option.provider)]
      end
    end

    trait :with_cancelled_interview do
      awaiting_provider_decision

      interviews do
        [build(:interview, :cancelled, provider: current_course_option.provider)]
      end
    end

    trait :withdrawn do
      application_form do
        association(:application_form, :submitted, **form_options)
      end
      status { :withdrawn }
      withdrawn_at { (sent_to_provider_at || Time.zone.now) + 1.second }
      withdrawn_or_declined_for_candidate_by_provider { false }
    end

    trait :with_structured_withdrawal_reasons do
      withdrawn
      structured_withdrawal_reasons { %w[concerns_about_cost course_not_available_anymore no_longer_want_to_train_to_teach] }
    end

    trait :withdrawn_at_candidates_request do
      withdrawn
      withdrawn_or_declined_for_candidate_by_provider { true }
    end

    trait :withdrawn_with_survey_completed do
      withdrawn
      withdrawal_feedback do
        {
          CandidateInterface::WithdrawalQuestionnaire::EXPLANATION_QUESTION => 'yes',
          'Explanation' => Faker::Lorem.paragraph_by_chars(number: 300),
          CandidateInterface::WithdrawalQuestionnaire::CONSENT_TO_BE_CONTACTED_QUESTION => 'yes',
          'Contact details' => Faker::PhoneNumber.cell_phone,
        }
      end
    end

    trait :offer_deferred do
      accepted
      status { 'offer_deferred' }
      status_before_deferral { 'pending_conditions' }
      offer_deferred_at { (accepted_at || Time.zone.now) + 1.second }
    end

    trait :offer_deferred_after_recruitment do
      recruited
      offer_deferred
      status_before_deferral { 'recruited' }
      offer_deferred_at { (recruited_at || Time.zone.now) + 1.second }
    end

    trait :offer_withdrawn do
      offered
      status { 'offer_withdrawn' }
      offer_withdrawal_reason { 'There has been a mistake' }
      offer_withdrawn_at { (offered_at || Time.zone.now) + 1.second }
    end

    trait :conditions_not_met do
      accepted
      status { 'conditions_not_met' }
      conditions_not_met_at { (accepted_at || Time.zone.now) + 1.second }

      offer { association(:offer, :with_unmet_conditions, application_choice: instance) }
    end

    trait :declined do
      offered
      status { 'declined' }
      withdrawn_or_declined_for_candidate_by_provider { false }
      declined_at { (offered_at || Time.zone.now) + 1.second }
    end

    trait :declined_by_default do
      declined

      declined_by_default { true }
    end

    trait :rejected do
      application_form do
        association(:application_form, :submitted, **form_options)
      end
      sent_to_provider_at { (application_form&.submitted_at || Time.zone.now) + 1.second }

      status { 'rejected' }
      rejection_reason { Faker::Lorem.paragraph_by_chars(number: 300) }
      rejection_reasons_type { 'rejection_reason' }
      rejected_at { (sent_to_provider_at || Time.zone.now) + 1.second }
    end

    trait :rejected_reason do
      rejected
    end

    trait :rejected_reasons do
      rejected
      rejection_reason { nil }
      rejection_reasons_type { 'rejection_reasons' }
      structured_rejection_reasons do
        {
          selected_reasons: [
            {
              id: 'qualifications',
              label: 'Qualifications',
              details: {
                id: 'qualifications_details', text: 'We could find no record of your GCSEs.'
              },
            },
            {
              id: 'personal_statement',
              label: 'Personal statement',
              details: {
                id: 'personal_statement_details', text: 'We do not accept applications written in Old Norse.'
              },
            },
            {
              id: 'references',
              label: 'References',
              details: {
                id: 'references_details',
                text: 'We do not accept references from close family members, such as your mum.',
              },
            },
          ],
        }
      end
    end

    trait :insufficient_a_levels_rejection_reasons do
      rejected
      rejection_reason { nil }
      rejection_reasons_type { 'rejection_reasons' }
      structured_rejection_reasons do
        {
          selected_reasons: [
            {
              id: 'qualifications',
              label: 'Qualifications',
              selected_reasons: [
                {
                  id: 'unsuitable_a_levels',
                  label: 'A levels do not meet course requirements (Teacher Degree Apprenticeship courses only)',
                  details: {
                    id: 'unsuitable_a_levels_details',
                    text: 'No sufficient grade',
                  },
                },
              ],
            },
          ],
        }
      end
    end

    trait :reasons_for_rejection do
      rejected
      rejection_reason { nil }
      rejection_reasons_type { 'reasons_for_rejection' }
      structured_rejection_reasons do
        {
          course_full_y_n: 'No',
          candidate_behaviour_y_n: 'Yes',
          candidate_behaviour_other: 'Persistent scratching',
          candidate_behaviour_what_to_improve: 'Not scratch so much',
          candidate_behaviour_what_did_the_candidate_do: %w[didnt_reply_to_interview_offer didnt_attend_interview other],
          honesty_and_professionalism_y_n: 'Yes',
          honesty_and_professionalism_concerns_other_details: nil,
          honesty_and_professionalism_concerns: %w[information_false_or_inaccurate references],
          honesty_and_professionalism_concerns_plagiarism_details: nil,
          honesty_and_professionalism_concerns_references_details: 'Clearly not a popular student',
          honesty_and_professionalism_concerns_information_false_or_inaccurate_details: 'Fake news',
          offered_on_another_course_y_n: 'No',
          offered_on_another_course_details: nil,
          performance_at_interview_y_n: 'Yes',
          performance_at_interview_what_to_improve: 'Be fully dressed',
          qualifications_y_n: 'Yes',
          qualifications_other_details: 'All the other stuff',
          qualifications_which_qualifications: %w[no_english_gcse other],
          quality_of_application_y_n: 'Yes',
          quality_of_application_other_details: 'Lights on but nobody home',
          quality_of_application_other_what_to_improve: 'Study harder',
          quality_of_application_which_parts_needed_improvement: %w[personal_statement subject_knowledge other],
          quality_of_application_subject_knowledge_what_to_improve: 'Claiming to be the \'world\'s leading expert\' seemed a bit strong',
          quality_of_application_personal_statement_what_to_improve: 'Use a spellchecker',
          safeguarding_y_n: 'Yes',
          safeguarding_concerns: %w[other],
          safeguarding_concerns_other_details: 'We need to run further checks',
          safeguarding_concerns_vetting_disclosed_information_details: nil,
          safeguarding_concerns_candidate_disclosed_information_details: nil,
          cannot_sponsor_visa_y_n: 'No',
          cannot_sponsor_visa_details: nil,
          interested_in_future_applications_y_n: nil,
          why_are_you_rejecting_this_application: nil,
          other_advice_or_feedback_y_n: nil,
          other_advice_or_feedback_details: nil,
        }
      end
    end

    trait :rejected_by_default do
      rejected

      rejected_by_default { true }
      rejection_reason { nil }
      rejection_reasons_type { nil }
    end

    trait :inactive do
      with_completed_application_form

      status { 'inactive' }
      inactive_at { Time.zone.now }
    end

    trait :rejected_by_default_with_feedback do
      rejected_by_default

      rejection_reason { Faker::Lorem.paragraph_by_chars(number: 200) }
      rejection_reasons_type { 'rejection_reason' }
      reject_by_default_feedback_sent_at { (rejected_at || Time.zone.now) + 1.second }

      after(:create) do |choice, evaluator|
        create(
          :application_choice_audit,
          :with_rejection_by_default_and_feedback,
          application_choice: choice,
        )
      end
    end

    trait :with_old_structured_rejection_reasons do
      rejected_by_default_with_feedback
      structured_rejection_reasons do
        {
          course_full_y_n: 'No',
          candidate_behaviour_y_n: 'Yes',
          candidate_behaviour_other: 'Persistent scratching',
          candidate_behaviour_what_to_improve: 'Not scratch so much',
          candidate_behaviour_what_did_the_candidate_do: %w[didnt_reply_to_interview_offer didnt_attend_interview other],
          honesty_and_professionalism_y_n: 'Yes',
          honesty_and_professionalism_concerns_other_details: nil,
          honesty_and_professionalism_concerns: %w[information_false_or_inaccurate references],
          honesty_and_professionalism_concerns_plagiarism_details: nil,
          honesty_and_professionalism_concerns_references_details: 'Clearly not a popular student',
          honesty_and_professionalism_concerns_information_false_or_inaccurate_details: 'Fake news',
          offered_on_another_course_y_n: 'No',
          offered_on_another_course_details: nil,
          performance_at_interview_y_n: 'Yes',
          performance_at_interview_what_to_improve: 'Be fully dressed',
          qualifications_y_n: 'Yes',
          qualifications_other_details: 'All the other stuff',
          qualifications_which_qualifications: %w[no_english_gcse other],
          quality_of_application_y_n: 'Yes',
          quality_of_application_other_details: 'Lights on but nobody home',
          quality_of_application_other_what_to_improve: 'Study harder',
          quality_of_application_which_parts_needed_improvement: %w[personal_statement subject_knowledge other],
          quality_of_application_subject_knowledge_what_to_improve: 'Claiming to be the \'world\'s leading expert\' seemed a bit strong',
          quality_of_application_personal_statement_what_to_improve: 'Use a spellchecker',
          safeguarding_y_n: 'Yes',
          safeguarding_concerns: %w[other],
          safeguarding_concerns_other_details: 'We need to run further checks',
          safeguarding_concerns_vetting_disclosed_information_details: nil,
          safeguarding_concerns_candidate_disclosed_information_details: nil,
          cannot_sponsor_visa_y_n: 'No',
          cannot_sponsor_visa_details: nil,
          interested_in_future_applications_y_n: nil,
          why_are_you_rejecting_this_application: nil,
          other_advice_or_feedback_y_n: nil,
          other_advice_or_feedback_details: nil,
        }
      end

      rejection_reasons_type { 'reasons_for_rejection' }
      rejection_reason { nil }

      after(:create) do |_choice, evaluator|
        create(
          :application_choice_audit,
          :with_rejection_by_default,
          application_choice: evaluator,
        )
      end
    end

    trait :with_structured_rejection_reasons do
      rejected_by_default_with_feedback
      structured_rejection_reasons do
        {
          selected_reasons: [
            { id: 'qualifications', label: 'Qualifications', selected_reasons: [
              { id: 'no_maths_gcse', label: 'No maths GCSE at minimum grade 4 or C, or equivalent' },
              { id: 'no_english_gcse', label: 'No English GCSE at minimum grade 4 or C, or equivalent' },
              { id: 'no_science_gcse', label: 'No science GCSE at minimum grade 4 or C, or equivalent' },
              { id: 'no_degree', label: 'No bachelor’s degree or equivalent' },
              { id: 'unverified_qualifications',
                label: 'Could not verify qualifications',
                details: { id: 'unverified_qualifications_details', text: 'We could find no record of your GCSEs.' } },
            ] },
            { id: 'personal_statement',
              label: 'Personal statement',
              selected_reasons: [
                { id: 'quality_of_writing',
                  label: 'Quality of writing',
                  details: { id: 'quality_of_writing_details', text: 'We do not accept applications written in Old Norse.' } },
              ] },
            { id: 'course_full',  label: 'Course full' },
            { id: 'other', label: 'Other', details: { id: 'other_details', text: 'So many other things were wrong...' } },
          ],
        }
      end

      rejection_reasons_type { 'rejection_reasons' }
      rejection_reason { nil }

      after(:create) do |_choice, evaluator|
        create(
          :application_choice_audit,
          :with_rejection_by_default,
          application_choice: evaluator,
        )
      end
    end

    trait :with_vendor_api_rejection_reasons do
      rejected_by_default_with_feedback
      structured_rejection_reasons do
        {
          selected_reasons: [
            {
              id: 'qualifications',
              label: 'Qualifications',
              details: {
                id: 'qualifications_details', text: 'We could find no record of your GCSEs.'
              },
            },
            {
              id: 'personal_statement',
              label: 'Personal statement',
              details: {
                id: 'personal_statement_details', text: 'We do not accept applications written in Old Norse.'
              },
            },
            {
              id: 'references',
              label: 'References',
              details: {
                id: 'references_details',
                text: 'We do not accept references from close family members, such as your mum.',
              },
            },
          ],
        }
      end
      rejection_reasons_type { 'vendor_api_rejection_reasons' }

      after(:create) do |_choice, evaluator|
        create(
          :application_choice_audit,
          :with_rejection_by_default,
          application_choice: evaluator,
        )
      end
    end
  end
end
