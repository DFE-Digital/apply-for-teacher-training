module SupportInterface
  class ProviderUserSummaryComponentPreview < ViewComponent::Preview
    def provider_user_summary
      provider_user = ProviderUserNotificationPreferences.limit(10).sample.provider_user

      render SupportInterface::ProviderUserSummaryComponent.new(provider_user)
    end
  end
end
