module SupportInterface
  class ProviderAccessControlsExport
    def data_for_export
      providers = Provider.all

      providers.map do |provider|
        {
          name: provider.name,
          dsa_signer: get_dsa_signer_email(provider),
          last_user_permissions_change_at: user_permissions_last_changed_at(provider),
          total_user_permissions_changes: total_user_permissions_changes(provider),
          user_permissions_changed_by: user_permissions_changed_by(provider),
          total_manage_users_users: total_manage_users_users(provider),
          total_manage_orgs_users: total_manage_orgs_users(provider),
          total_users: provider.provider_users.count,
          last_org_permissions_change_at: org_permissions_last_changed_at(provider),
          total_org_permissions_changes: total_org_permissions_changes(provider),
          org_permissions_changed_by: org_permissions_changed_by(provider),
          total_org_relationships_as_trainer: total_org_relationships_as_trainer(provider),
          total_org_relationships: total_org_relationships(provider),
        }
      end
    end

  private

    def get_dsa_signer_email(provider)
      provider
        .provider_agreements
        .data_sharing_agreements
        .where.not(accepted_at: nil)
        .order(accepted_at: :desc)
        .first
        .provider_user
        .email_address
    end

    def user_permissions_audits(provider)
      Audited::Audit.where(action: 'update', auditable: provider.provider_permissions)
    end

    def user_permissions_last_changed_at(provider)
      user_permissions_audits(provider)
        .order(created_at: :desc)
        .pick(:created_at)
    end

    def total_user_permissions_changes(provider)
      user_permissions_audits(provider).count
    end

    def user_permissions_changed_by(provider)
      user_permissions_audits(provider)
        .map { |audit| audit.user.email_address }
        .uniq
    end

    def total_manage_users_users(provider)
      provider.provider_permissions.where(manage_users: true).count
    end

    def total_manage_orgs_users(provider)
      provider.provider_permissions.where(manage_organisations: true).count
    end

    def org_training_provider_permission_audits(provider)
      Audited::Audit.where(action: 'update', auditable: provider.training_provider_permissions)
    end

    def org_permissions_last_changed_at(provider)
      org_training_provider_permission_audits(provider)
        .order(created_at: :desc)
        .pick(:created_at)
    end

    def total_org_permissions_changes(provider)
      org_training_provider_permission_audits(provider).count
    end

    def org_permissions_changed_by(provider)
      org_training_provider_permission_audits(provider)
        .map { |audit| audit.user.email_address }
        .uniq
    end

    def total_org_relationships_as_trainer(provider)
      provider.training_provider_permissions.count
    end

    def total_org_relationships(provider)
      (provider.ratifying_provider_permissions + provider.training_provider_permissions)
        .uniq
        .count
    end
  end
end
