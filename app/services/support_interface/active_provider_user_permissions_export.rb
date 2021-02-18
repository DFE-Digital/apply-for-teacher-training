module SupportInterface
  class ActiveProviderUserPermissionsExport
    def data_for_export(run_once_flag = false)
      active_provider_users = ProviderUser.includes(:providers).where.not(last_signed_in_at: nil)

      active_provider_users.flat_map { |provider_user| data_for_user(provider_user, run_once_flag) }
    end

  private

    def data_for_user(provider_user, run_once_flag = false )
      provider_user.providers.map do |provider|
        permissions = provider_user.provider_permissions
        {
          name: provider_user.full_name,
          email_address: provider_user.email_address,
          provider: provider.name,
          last_signed_in_at: provider_user.last_signed_in_at,
          has_make_decisions: permissions.make_decisions.exists?(provider: provider),
          has_view_safeguarding: permissions.view_safeguarding_information.exists?(provider: provider),
          has_view_diversity: permissions.view_diversity_information.exists?(provider: provider),
          has_manage_users: permissions.manage_users.exists?(provider: provider),
          has_manage_organisations: permissions.manage_organisations.exists?(provider: provider),
        }
        break if run_once_flag
      end
    end
  end
end
