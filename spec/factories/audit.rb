FactoryBot.define do
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
end
