module SupportInterface
  class ProviderUserPermissionsSummaryComponentPreview < ViewComponent::Preview
    def provider_user_permission_summary
      provider_user = ProviderUserNotificationPreferences.limit(10).sample.provider_user

      render SupportInterface::ProviderUserPermissionsSummaryComponent.new(provider_user)
    end
  end
end
