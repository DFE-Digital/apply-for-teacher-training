module SupportInterface
  class ActiveProviderUserPermissionsExport
    def data_for_export
      active_provider_users = ProviderUser.includes(:providers).where.not(last_signed_in_at: nil)

      active_provider_users.find_each(batch_size: 100).flat_map { |provider_user| data_for_user(provider_user) }
    end

  private

    def data_for_user(provider_user)
      provider_user.providers.map do |provider|
        permissions = provider_user.provider_permissions
        user_data =
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

        if FeatureFlag.active?(:interview_permissions)
          user_data.merge!(has_set_up_interviews: permissions.set_up_interviews.exists?(provider: provider))
        end

        user_data
      end
    end
  end
end
