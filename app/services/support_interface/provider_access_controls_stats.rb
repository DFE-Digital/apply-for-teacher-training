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

    def user_permissions_audits
      @_user_permissions_audits ||= Audited::Audit.where(action: 'update', auditable: @provider.provider_permissions)
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
        .map { |audit| audit.user.email_address }
        .uniq
    end

    def total_manage_users_users
      @provider.provider_permissions.where(manage_users: true).count
    end

    def total_manage_orgs_users
      @provider.provider_permissions.where(manage_organisations: true).count
    end

    def org_training_provider_permission_audits
      @_org_permissions_audits ||= Audited::Audit.where(action: 'update', auditable: @provider.training_provider_permissions)
    end

    def org_permissions_last_changed_at
      org_training_provider_permission_audits
        .order(created_at: :desc)
        .pick(:created_at)
    end

    def total_org_permissions_changes
      org_training_provider_permission_audits.count
    end

    def org_permissions_changed_by
      org_training_provider_permission_audits
        .map { |audit| audit.user.email_address }
        .uniq
    end

    def total_org_relationships_as_trainer
      @provider.training_provider_permissions.count
    end

    def total_org_relationships
      (@provider.ratifying_provider_permissions + @provider.training_provider_permissions)
        .uniq
        .count
    end
  end
end
