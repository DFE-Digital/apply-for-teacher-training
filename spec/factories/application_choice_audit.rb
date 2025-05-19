FactoryBot.define do
  factory :application_choice_audit, class: 'Audited::Audit' do
    action { 'update' }
    user { create(:support_user) }
    version { 1 }
    request_uuid { SecureRandom.uuid }
    created_at { Time.zone.now }

    transient do
      application_choice { create(:application_choice, :awaiting_provider_decision) }
      changes { {} }
    end

    after(:build) do |audit, evaluator|
      audit.auditable_type = 'ApplicationChoice'
      audit.auditable_id = evaluator.application_choice.id
      audit.auditable = evaluator.application_choice
      audit.associated = evaluator.application_choice.application_form
      audit.audited_changes = evaluator.changes
    end

    trait :awaiting_provider_decision do
      changes do
        { 'status' => %w[unsubmitted awaiting_provider_decision] }
      end
    end

    trait :withdrawn do
      changes do
        { 'status' => %w[awaiting_provider_decision withdrawn] }
      end
    end

    trait :with_rejection do
      application_choice factory: %i[application_choice rejected]

      changes do
        { 'status' => %w[awaiting_provider_decision rejected] }
      end
    end

    trait :with_rejection_by_default do
      application_choice { create(:application_choice, :rejected_by_default) }

      changes do
        { 'status' => %w[awaiting_provider_decision rejected] }
      end

      after(:build) do |audit, _evaluator|
        audit.auditable.rejected_by_default = true
      end
    end

    trait :with_rejection_by_default_and_feedback do
      application_choice factory: %i[application_choice rejected_by_default_with_feedback]

      changes do
        { 'reject_by_default_feedback_sent_at' => [nil, Time.zone.now.iso8601] }
      end
    end

    trait :with_declined_offer do
      application_choice factory: %i[application_choice declined]

      changes do
        { 'status' => %w[offer declined] }
      end
    end

    trait :with_declined_by_default_offer do
      application_choice factory: %i[application_choice declined_by_default]

      changes do
        { 'status' => %w[offer declined] }
      end

      after(:build) do |audit, _evaluator|
        audit.auditable.declined_by_default = true
      end
    end

    trait :with_offer do
      application_choice factory: %i[application_choice offered]

      changes do
        {
          'status' => %w[awaiting_provider_decision offer],
        }
      end
    end

    trait :with_inactive_offer do
      application_choice factory: %i[application_choice offered]

      changes do
        {
          'status' => %w[inactive offer],
        }
      end
    end

    trait :with_withdrawn_offer do
      application_choice factory: %i[application_choice offer_withdrawn]

      changes do
        { 'status' => %w[offer offer_withdrawn] }
      end
    end

    trait :with_modified_offer do
      application_choice factory: %i[application_choice course_changed_before_offer]

      changes do
        {
          'status' => %w[awaiting_provider_decision offer],
          'current_course_option_id' => [application_choice.course_option_id, application_choice.current_course_option_id],
        }
      end
    end

    trait :with_old_modified_offer do
      application_choice factory: %i[application_choice course_changed_before_offer]

      changes do
        {
          'status' => %w[awaiting_provider_decision offer],
          'current_course_option_id' => [application_choice.course_option_id, application_choice.current_course_option_id],
        }
      end
    end

    trait :with_changed_offer do
      application_choice factory: %i[application_choice course_changed_after_offer]

      changes do
        {
          'offer_changed_at' => [nil, Time.zone.now.iso8601],
          'current_course_option_id' => [application_choice.course_option_id, application_choice.current_course_option_id],
        }
      end
    end

    trait :with_changed_course do
      application_choice factory: %i[application_choice course_changed]

      changes do
        {
          'course_changed_at' => [nil, Time.zone.now.iso8601],
          'course_option_id' => [application_choice.course_option_id, application_choice.current_course_option_id],
          'curent_course_option_id' => [application_choice.course_option_id, application_choice.current_course_option_id],
        }
      end
    end

    trait :with_old_changed_offer do
      application_choice factory: %i[application_choice course_changed_after_offer]

      changes do
        {
          'offer_changed_at' => [nil, Time.zone.now.iso8601],
          'current_course_option_id' => [application_choice.course_option_id, application_choice.current_course_option_id],
        }
      end
    end

    trait :with_accepted_offer do
      application_choice factory: %i[application_choice accepted]

      changes do
        { 'status' => %w[offer pending_conditions] }
      end
    end

    trait :with_conditions_not_met do
      application_choice factory: %i[application_choice conditions_not_met]

      changes do
        { 'status' => %w[pending_conditions conditions_not_met] }
      end
    end

    trait :with_recruited do
      application_choice factory: %i[application_choice recruited]

      changes do
        { 'status' => %w[pending_conditions recruited] }
      end
    end

    trait :with_deferred_offer do
      application_choice factory: %i[application_choice offer_deferred]

      changes do
        { 'status' => %w[pending_conditions offer_deferred] }
      end
    end

    trait :with_scheduled_interview do
      application_choice factory: %i[application_choice interviewing]

      changes do
        { 'status' => %w[awaiting_provider_decision interviewing] }
      end
    end

    trait :with_cancelled_interview do
      application_choice factory: %i[application_choice with_cancelled_interview]

      changes do
        { 'status' => %w[awaiting_provider_decision] }
      end
    end
  end
end
