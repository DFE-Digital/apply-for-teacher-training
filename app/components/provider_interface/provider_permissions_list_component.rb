module ProviderInterface
  class ProviderPermissionsListComponent < ViewComponent::Base
    include ViewHelper
    attr_reader :provider_permissions, :possible_permissions

    def initialize(provider_permissions:, possible_permissions:)
      @provider_permissions = provider_permissions
      @possible_permissions = possible_permissions
    end

    def visible_provider_permissions
      possible_permissions & provider_permissions
    end
  end
end
