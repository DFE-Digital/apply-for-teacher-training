module SupportInterface
  class ActiveProviderUsersExport
    def data_for_export
      active_provider_users = ProviderUser.includes(:providers).where.not(last_signed_in_at: nil)

      active_provider_users.find_each(batch_size: 100).map do |provider_user|
        {
          provider_full_name: provider_user.full_name,
          provider_email_address: provider_user.email_address,
          providers: provider_user.providers.map(&:name).join(', '),
          last_signed_in_at: provider_user.last_signed_in_at,
        }
      end
    end
  end
end
