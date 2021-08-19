module ProviderInterface
  class UserCardComponent < ViewComponent::Base
    include ViewHelper

    attr_reader :provider_user, :provider

    def initialize(provider_user:, provider:)
      @provider_user = provider_user
      @provider = provider
    end

    def provider_user_permissions
      @provider_user_permissions ||= begin
        provider_permission = provider_user.provider_permissions.find_by(provider: provider)
        ProviderPermissions::VALID_PERMISSIONS.select { |permission| provider_permission.send(permission) }
      end
    end
  end
end
