module SupportInterface
  class ProviderAccessControlsStats
    def initialize(provider)
      @provider = provider
    end

    def dsa_signer_email
      @provider
        .provider_agreements
        .data_sharing_agreements
        .where.not(accepted_at: nil)
        .order(accepted_at: :desc)
        .first
        &.provider_user
        &.email_address
    end

    def user_permissions_last_changed_at
      user_permissions_audits
        .order(created_at: :desc)
        .pick(:created_at)
    end

    def total_user_permissions_changes
      user_permissions_audits.count
    end

    def user_permissions_changed_by
      user_permissions_audits
        .map { |audit| audit.user&.email_address }
        .compact
        .uniq
        .sort
    end

    def total_user_permissions_changes_made_by_support
      Audited::Audit.where(action: 'update', auditable: @provider.provider_permissions, user_type: 'SupportUser').count
    end

    def total_manage_users_users
      @provider.provider_permissions.where(manage_users: true).count
    end

    def total_manage_orgs_users
      @provider.provider_permissions.where(manage_organisations: true).count
    end

    def date_of_last_org_permissions_change_made_by_this_provider_affecting_this_provider
      date_of_last(:org_permissions_changes_made_by_this_provider_affecting_this_provider)
    end

    def total_org_permissions_changes_made_by_this_provider_affecting_this_provider
      total(:org_permissions_changes_made_by_this_provider_affecting_this_provider)
    end

    def total_org_permissions_changes_made_by_support
      total(:org_permissions_changes_made_by_support)
    end

    def org_permissions_changes_made_by_this_provider_affecting_this_provider_made_by
      provider_user_emails_who_made(:org_permissions_changes_made_by_this_provider_affecting_this_provider)
    end

    def date_of_last_org_permissions_change_made_by_this_provider_affecting_another_provider
      date_of_last(:org_permissions_changes_made_by_this_provider_affecting_another_provider)
    end

    def total_org_permissions_changes_made_by_this_provider_affecting_another_provider
      total(:org_permissions_changes_made_by_this_provider_affecting_another_provider)
    end

    def org_permissions_changes_made_by_this_provider_affecting_another_provider_made_by
      provider_user_emails_who_made(:org_permissions_changes_made_by_this_provider_affecting_another_provider)
    end

    def date_of_last_org_permissions_change_affecting_this_provider
      date_of_last(:org_permissions_changes_affecting_this_provider)
    end

    def total_org_permissions_changes_affecting_this_provider
      total(:org_permissions_changes_affecting_this_provider)
    end

    def org_permissions_changes_affecting_this_provider_made_by
      provider_user_emails_who_made(:org_permissions_changes_affecting_this_provider)
    end

    def total_org_relationships_as_trainer
      @provider.training_provider_permissions.count
    end

    def total_org_relationships
      (@provider.ratifying_provider_permissions + @provider.training_provider_permissions)
        .uniq
        .count
    end

  private

    def training_provider_permissions_keys
      @training_provider_permissions_keys ||= ProviderRelationshipPermissions::PERMISSIONS.map { |permission| "training_provider_can_#{permission}" }
    end

    def ratifying_provider_permissions_keys
      @ratifying_provider_permissions_keys ||= ProviderRelationshipPermissions::PERMISSIONS.map { |permission| "ratifying_provider_can_#{permission}" }
    end

    def user_permissions_audits
      @_user_permissions_audits ||= Audited::Audit.where(action: 'update', auditable: @provider.provider_permissions, user_type: 'ProviderUser')
    end

    def org_training_provider_permission_audits
      @_org_training_provider_permission_audits ||= Audited::Audit
                                                      .where(action: 'update', auditable: @provider.training_provider_permissions, user_type: %w[ProviderUser SupportUser])
    end

    def org_ratifying_provider_permission_audits
      @_org_ratifying_provider_permission_audits ||= Audited::Audit
                                                       .where(action: 'update', auditable: @provider.ratifying_provider_permissions, user_type: %w[ProviderUser SupportUser])
    end

    def org_training_provider_permission_audits_made_by(user_type)
      org_training_provider_permission_audits.where(user_type:)
    end

    def org_ratifying_provider_permission_audits_made_by(user_type)
      org_ratifying_provider_permission_audits.where(user_type:)
    end

    def audits_for_org_permissions_changes_affecting_this_training_provider_made_by(user_type)
      org_training_provider_permission_audits_made_by(user_type)
        .where('audited_changes ?| array[:keys]', keys: training_provider_permissions_keys)
    end

    def audits_for_org_permissions_changes_affecting_this_ratifying_provider_made_by(user_type)
      org_ratifying_provider_permission_audits_made_by(user_type)
        .where('audited_changes ?| array[:keys]', keys: ratifying_provider_permissions_keys)
    end

    def audits_for_org_permissions_changes_made_by_this_provider_affecting_this_provider
      audits_for_org_permissions_changes_affecting_this_training_provider_made_by('ProviderUser')
    end

    def audits_for_org_permissions_changes_made_by_this_provider_affecting_another_provider
      org_training_provider_permission_audits_made_by('ProviderUser')
        .where('audited_changes ?| array[:keys]', keys: ratifying_provider_permissions_keys)
    end

    def audits_for_org_permissions_changes_made_by_another_provider_affecting_this_provider
      audits_for_org_permissions_changes_affecting_this_ratifying_provider_made_by('ProviderUser')
    end

    def audits_for_org_permissions_changes_affecting_this_provider
      org_training_provider_permission_audits.where('audited_changes ?| array[:keys]', keys: training_provider_permissions_keys)
        .or(org_ratifying_provider_permission_audits.where('audited_changes ?| array[:keys]', keys: ratifying_provider_permissions_keys))
    end

    def audits_for_org_permissions_changes_made_by_support
      audits_for_org_permissions_changes_affecting_this_training_provider_made_by('SupportUser')
        .or(audits_for_org_permissions_changes_affecting_this_ratifying_provider_made_by('SupportUser'))
    end

    def date_of_last(permission_change)
      send("audits_for_#{permission_change}")
        .order(created_at: :desc)
        .pick(:created_at)
    end

    def total(permission_change)
      send("audits_for_#{permission_change}").count
    end

    def provider_user_emails_who_made(permission_change)
      send("audits_for_#{permission_change}")
        .map { |audit| audit.user&.email_address }
        .compact
        .uniq
        .sort
    end
  end
end
