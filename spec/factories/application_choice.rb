FactoryBot.define do
  factory :application_choice do
    course_option
    application_form

    status { ApplicationStateChange.valid_states.sample }

    trait :with_completed_application_form do
      association :application_form, factory: %i[completed_application_form]
    end

    trait :application_form_with_degree do
      association :application_form, factory: %i[completed_application_form with_degree]
    end

    factory :submitted_application_choice do
      status { 'awaiting_provider_decision' }
      reject_by_default_at { 40.business_days.from_now }
      reject_by_default_days { 40 }
    end

    trait :awaiting_provider_decision do
      status { :awaiting_provider_decision }

      reject_by_default_days { 40 }
      reject_by_default_at { 40.business_days.from_now }
    end

    trait :with_scheduled_interview do
      awaiting_provider_decision

      after(:build) do |application_choice, _evaluator|
        application_choice.status = :interviewing
        application_choice.interviews << build(:interview, provider: application_choice.provider)
      end
    end

    trait :with_cancelled_interview do
      awaiting_provider_decision

      after(:build) do |application_choice, _evaluator|
        application_choice.status = :awaiting_provider_decision
        application_choice.interviews << build(:interview, :cancelled, provider: application_choice.provider)
      end
    end

    trait :withdrawn do
      status { :withdrawn }
      withdrawn_at { Time.zone.now }
    end

    trait :dbd do
      with_offer

      status { :declined }
      declined_by_default { true }
      decline_by_default_days { 10 }
    end

    trait :withdrawn_with_survey_completed do
      status { :withdrawn }
      withdrawn_at { Time.zone.now }
      withdrawal_feedback do
        {
          CandidateInterface::WithdrawalQuestionnaire::EXPLANATION_QUESTION => 'yes',
          'Explanation' => Faker::Lorem.paragraph_by_chars(number: 300),
          CandidateInterface::WithdrawalQuestionnaire::CONSENT_TO_BE_CONTACTED_QUESTION => 'yes',
          'Contact details' => Faker::PhoneNumber.cell_phone,
        }
      end
    end

    trait :with_rejection do
      status { 'rejected' }
      rejection_reason { Faker::Lorem.paragraph_by_chars(number: 300) }
      rejected_at { Time.zone.now }
    end

    trait :with_rejection_by_default do
      status { 'rejected' }
      rejected_at { 2.minutes.ago }
      rejected_by_default { true }
    end

    trait :with_rejection_by_default_and_feedback do
      with_rejection_by_default
      rejection_reason { Faker::Lorem.paragraph_by_chars(number: 200) }
      reject_by_default_feedback_sent_at { Time.zone.now }

      after(:create) do |_choice, evaluator|
        create(
          :application_choice_audit,
          :with_rejection_by_default_and_feedback,
          application_choice: evaluator,
        )
      end
    end

    trait :with_structured_rejection_reasons do
      with_rejection_by_default
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
          interested_in_future_applications_y_n: nil,
          why_are_you_rejecting_this_application: nil,
          other_advice_or_feedback_y_n: nil,
          other_advice_or_feedback_details: nil,
        }
      end
      reject_by_default_feedback_sent_at { Time.zone.now }

      after(:create) do |_choice, evaluator|
        create(
          :application_choice_audit,
          :with_rejection_by_default,
          application_choice: evaluator,
        )
      end
    end

    trait :application_not_sent do
      status { 'application_not_sent' }
      rejected_at { Time.zone.now }
      rejection_reason { 'Awaiting references when the recruitment cycle closed.' }
    end

    trait :with_offer do
      status { 'offer' }
      decline_by_default_at { 10.business_days.from_now }
      decline_by_default_days { 10 }
      offer { { 'conditions' => ['Be cool'] } }
      offered_at { Time.zone.now }
    end

    trait :with_modified_offer do
      with_offer

      after(:build) do |choice, _evaluator|
        other_course = create(:course, provider: choice.course_option.course.provider)
        choice.offered_course_option_id = create(:course_option, course: other_course).id
        choice.offered_at = 3.business_days.ago
        choice.decline_by_default_at = 7.business_days.from_now
      end
    end

    trait :with_changed_offer do
      with_offer

      after(:build) do |choice, _evaluator|
        other_course = create(:course, provider: choice.course_option.course.provider)
        choice.offered_course_option_id = create(:course_option, course: other_course).id
        choice.offer_changed_at = Time.zone.now - 1.day
      end
    end

    trait :with_accepted_offer do
      with_offer
      status { 'pending_conditions' }
      accepted_at { Time.zone.now - 2.days }
    end

    trait :with_declined_offer do
      with_offer
      status { 'declined' }
      declined_at { Time.zone.now - 2.days }
    end

    trait :with_declined_by_default_offer do
      with_offer
      status { 'declined' }
      declined_at { Time.zone.now }
      declined_by_default { true }
    end

    trait :with_withdrawn_offer do
      with_offer
      status { 'offer_withdrawn' }
      offer_withdrawal_reason { 'There has been a mistake' }
      offer_withdrawn_at { Time.zone.now - 1.day }
    end

    trait :with_conditions_not_met do
      with_accepted_offer
      status { 'conditions_not_met' }
      conditions_not_met_at { Time.zone.now }
    end

    trait :with_recruited do
      with_accepted_offer
      status { 'recruited' }
      recruited_at { Time.zone.now }
    end

    trait :with_deferred_offer do
      with_accepted_offer
      status { 'offer_deferred' }
      status_before_deferral { 'pending_conditions' }
      offer_deferred_at { Time.zone.now - 1.day }
    end

    trait :with_deferred_offer_previously_recruited do
      with_deferred_offer
      status_before_deferral { 'recruited' }
      recruited_at { Time.zone.now - 1.day }
    end

    trait :previous_year do
      association :course_option, :previous_year

      after(:create) do |choice, _evaluator|
        choice.application_form.update_columns(recruitment_cycle_year: RecruitmentCycle.previous_year)
      end
    end

    trait :previous_year_but_still_available do
      association :course_option, :previous_year_but_still_available

      after(:create) do |choice, _evaluator|
        choice.application_form.update_columns(recruitment_cycle_year: RecruitmentCycle.previous_year)
      end
    end
  end
end
