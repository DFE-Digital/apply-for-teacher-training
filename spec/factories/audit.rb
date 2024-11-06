FactoryBot.define do
  factory :audit, class: 'Audited::Audit'

  factory :application_experience_audit, class: 'Audited::Audit' do
    action { 'create' }
    user { create(:support_user) }
    version { 1 }
    request_uuid { SecureRandom.uuid }
    created_at { Time.zone.now }

    transient do
      application_experience { build_stubbed(:application_work_experience) }
      application_choice { build_stubbed(:application_choice, :awaiting_provider_decision) }
      changes { {} }
    end

    after(:build) do |audit, evaluator|
      audit.auditable_type = 'ApplicationExperience'
      audit.auditable_id = evaluator.application_experience.id
      audit.associated = evaluator.application_choice
      audit.user_type = evaluator.user.class.to_s unless evaluator.username == '(Automated process)'
      audit.audited_changes = evaluator.changes
    end
  end

  factory :application_work_history_break_audit, class: 'Audited::Audit' do
    action { 'create' }
    user { create(:support_user) }
    version { 1 }
    request_uuid { SecureRandom.uuid }
    created_at { Time.zone.now }

    transient do
      application_work_history_break { build_stubbed(:application_work_history_break) }
      application_choice { build_stubbed(:application_choice, :awaiting_provider_decision) }
      changes { {} }
    end

    after(:build) do |audit, evaluator|
      audit.auditable_type = 'ApplicationWorkHistoryBreak'
      audit.auditable_id = evaluator.application_work_history_break.id
      audit.associated = evaluator.application_choice
      audit.user_type = evaluator.user.class.to_s unless evaluator.username == '(Automated process)'
      audit.audited_changes = evaluator.changes
    end
  end

  factory :withdrawn_at_candidates_request_audit, class: 'Audited::Audit' do
    action { 'update' }
    user { create(:provider_user) }
    version { 1 }
    request_uuid { SecureRandom.uuid }
    comment { 'Withdrawn on behalf of the candidate' }
    created_at { Time.zone.now }

    transient do
      application_choice { build_stubbed(:application_choice, :withdrawn) }
      changes { {} }
    end

    after(:build) do |audit, evaluator|
      audit.auditable_type = 'ApplicationChoice'
      audit.auditable_id = evaluator.application_choice.id
      audit.audited_changes = evaluator.changes
    end
  end

  factory :declined_at_candidates_request_audit, class: 'Audited::Audit' do
    action { 'update' }
    user { create(:provider_user) }
    version { 1 }
    request_uuid { SecureRandom.uuid }
    comment { 'Declined on behalf of the candidate' }
    created_at { Time.zone.now }

    transient do
      application_choice { build_stubbed(:application_choice, :declined) }
      changes { {} }
    end

    after(:build) do |audit, evaluator|
      audit.auditable_type = 'ApplicationChoice'
      audit.auditable_id = evaluator.application_choice.id
      audit.audited_changes = evaluator.changes
    end
  end

  factory :interview_audit, class: 'Audited::Audit' do
    action { 'create' }
    user { create(:provider_user) }
    version { 1 }
    request_uuid { SecureRandom.uuid }
    created_at { Time.zone.now }

    transient do
      application_choice { build_stubbed(:application_choice, :awaiting_provider_decision) }
      interview { build_stubbed(:interview) }
      changes { {} }
    end

    after(:build) do |audit, evaluator|
      audit.auditable_type = 'Interview'
      audit.auditable_id = evaluator.interview.id
      audit.associated = evaluator.interview.application_choice
      audit.user_type = evaluator.user.class.to_s
      audit.audited_changes = evaluator.changes
    end
  end

  factory :provider_permissions_audit, class: 'Audited::Audit' do
    action { 'update' }
    user { create(:provider_user) }
    version { 1 }
    request_uuid { SecureRandom.uuid }
    created_at { Time.zone.now }

    transient do
      provider_permissions { build_stubbed(:provider_permissions) }
      changes { {} }
    end

    after(:build) do |audit, evaluator|
      audit.auditable_type = 'ProviderPermissions'
      audit.auditable_id = evaluator.provider_permissions.id
      audit.audited_changes = evaluator.changes
    end
  end

  factory :provider_relationship_permissions_audit, class: 'Audited::Audit' do
    action { 'update' }
    user { create(:provider_user) }
    version { 1 }
    request_uuid { SecureRandom.uuid }
    created_at { Time.zone.now }

    transient do
      provider_relationship_permissions { build_stubbed(:provider_relationship_permissions) }
      changes { {} }
    end

    after(:build) do |audit, evaluator|
      audit.auditable_type = 'ProviderRelationshipPermissions'
      audit.auditable_id = evaluator.provider_relationship_permissions.id
      audit.audited_changes = evaluator.changes
    end
  end

  factory :provider_user_notification_preferences_audit, class: 'Audited::Audit' do
    action { 'update' }
    user { create(:provider_user) }
    version { 1 }
    request_uuid { SecureRandom.uuid }
    created_at { Time.zone.now }

    transient do
      notification_preferences { build_stubbed(:provider_user_notification_preferences) }
      changes { {} }
    end

    after(:build) do |audit, evaluator|
      audit.auditable_type = 'ProviderUserNotificationPreferences'
      audit.auditable_id = evaluator.notification_preferences.id
      audit.audited_changes = evaluator.changes
    end
  end

  factory :application_form_audit, class: 'Audited::Audit' do
    action { 'update' }
    user { create(:provider_user) }
    version { 1 }
    request_uuid { SecureRandom.uuid }
    created_at { Time.zone.now }

    transient do
      application_choice { build_stubbed(:application_choice) }
      changes { {} }
    end

    after(:build) do |audit, evaluator|
      audit.auditable_type = 'ApplicationForm'
      audit.auditable_id = evaluator.application_choice.application_form.id
      audit.audited_changes = evaluator.changes
    end
  end
end
