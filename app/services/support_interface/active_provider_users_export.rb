module SupportInterface
  class ActiveProviderUsersExport
    def data_for_export(run_once_flag = false)
      active_provider_users = ProviderUser.includes(:providers).where.not(last_signed_in_at: nil)

      active_provider_users.each do |provider_user|
        {
          name: provider_user.full_name,
          email_address: provider_user.email_address,
          providers: provider_user.providers.map(&:name).join(', '),
          last_signed_in_at: provider_user.last_signed_in_at,
        }
        break if run_once_flag
      end
    end
  end
end
