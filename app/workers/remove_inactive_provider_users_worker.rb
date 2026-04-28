class RemoveInactiveProviderUsersWorker
  include Sidekiq::Worker

  sidekiq_options queue: :low_priority

  INACTIVE_MONTHS_AGO = 12

  def perform
    ProviderUser.where('last_signed_in_at < ?', INACTIVE_MONTHS_AGO.months.ago)
      .or(ProviderUser.where(
            'last_signed_in_at IS NULL AND created_at < ?', INACTIVE_MONTHS_AGO.months.ago
          )).each do |provider_user|
      provider_user.provider_permissions.each do |permissions_to_remove|
        SupportInterface::RemoveUserFromProvider.new(permissions_to_remove:).call!
      end
    end
  end
end
