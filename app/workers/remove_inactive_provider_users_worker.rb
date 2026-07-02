class RemoveInactiveProviderUsersWorker < ApplicationJob
  queue_as :low_priority

  INACTIVE_MONTHS_AGO = 12

  def perform
    return if HostingEnvironment.qa? || HostingEnvironment.review? || HostingEnvironment.development?

    ProviderUser.where('last_signed_in_at < ?', INACTIVE_MONTHS_AGO.months.ago)
      .or(ProviderUser.where(
            'last_signed_in_at IS NULL AND created_at < ?', INACTIVE_MONTHS_AGO.months.ago
          )).each do |provider_user|
      # Skip if they were re-added recently (permissions created within the last week)
      next if provider_user.provider_permissions.exists?(['created_at > ?', 1.week.ago])

      provider_user.provider_permissions.each do |permissions_to_remove|
        SupportInterface::RemoveUserFromProvider.new(permissions_to_remove:).call!
      end
    end
  end
end
