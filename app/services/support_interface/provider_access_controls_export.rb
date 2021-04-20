module SupportInterface
  class ProviderAccessControlsExport
    def data_for_export
      providers = Provider.where(sync_courses: true)

      providers.find_each(batch_size: 100).map do |provider|
        access_controls = ProviderAccessControlsStats.new(provider)
        {
          provider_name: provider.name,
          provider_code: provider.code,
          dsa_signer: access_controls.dsa_signer_email,
          last_user_permissions_change_at: access_controls.user_permissions_last_changed_at,
          total_user_permissions_changes: access_controls.total_user_permissions_changes,
          user_permissions_changed_by: access_controls.user_permissions_changed_by,
          total_user_permissions_changes_made_by_support: access_controls.total_user_permissions_changes_made_by_support,
          total_manage_users_users: access_controls.total_manage_users_users,
          total_manage_orgs_users: access_controls.total_manage_orgs_users,
          total_users: provider.provider_users.count,
          org_permissions_changes_made_by_this_provider_affecting_this_provider_last_made_at: access_controls.date_of_last_org_permissions_change_made_by_this_provider_affecting_this_provider,
          total_org_permissions_changes_made_by_this_provider_affecting_this_provider: access_controls.total_org_permissions_changes_made_by_this_provider_affecting_this_provider,
          org_permissions_changes_made_by_this_provider_affecting_this_provider_made_by: access_controls.org_permissions_changes_made_by_this_provider_affecting_this_provider_made_by,
          org_permissions_changes_made_by_this_provider_affecting_another_provider_last_made_at: access_controls.date_of_last_org_permissions_change_made_by_this_provider_affecting_another_provider,
          total_org_permissions_changes_made_by_this_provider_affecting_another_provider: access_controls.total_org_permissions_changes_made_by_this_provider_affecting_another_provider,
          org_permissions_changes_made_by_this_provider_affecting_another_provider_made_by: access_controls.org_permissions_changes_made_by_this_provider_affecting_another_provider_made_by,
          org_permissions_changes_affecting_this_provider_last_made_at: access_controls.date_of_last_org_permissions_change_affecting_this_provider,
          total_org_permissions_changes_affecting_this_provider: access_controls.total_org_permissions_changes_affecting_this_provider,
          total_org_permissions_changes_made_by_support: access_controls.total_org_permissions_changes_made_by_support,
          org_permissions_changes_affecting_this_provider_made_by: access_controls.org_permissions_changes_affecting_this_provider_made_by,
          total_org_relationships_as_trainer: access_controls.total_org_relationships_as_trainer,
          total_org_relationships: access_controls.total_org_relationships,
        }
      end
    end
  end
end
