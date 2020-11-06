module SupportInterface
  class ProviderAccessControlsExport
    def data_for_export
      providers = Provider.all

      providers.map do |provider|
        access_controls = ProviderAccessControls.new(provider)
        {
          name: provider.name,
          dsa_signer: access_controls.dsa_signer_email,
          last_user_permissions_change_at: access_controls.user_permissions_last_changed_at,
          total_user_permissions_changes: access_controls.total_user_permissions_changes,
          user_permissions_changed_by: access_controls.user_permissions_changed_by,
          total_manage_users_users: access_controls.total_manage_users_users,
          total_manage_orgs_users: access_controls.total_manage_orgs_users,
          total_users: provider.provider_users.count,
          last_org_permissions_change_at: access_controls.org_permissions_last_changed_at,
          total_org_permissions_changes: access_controls.total_org_permissions_changes,
          org_permissions_changed_by: access_controls.org_permissions_changed_by,
          total_org_relationships_as_trainer: access_controls.total_org_relationships_as_trainer,
          total_org_relationships: access_controls.total_org_relationships,
        }
      end
    end
  end
end
