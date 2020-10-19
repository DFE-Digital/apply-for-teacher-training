module SupportInterface
  class ProviderUserPermissionsComponent < ViewComponent::Base
    include ViewHelper

    def initialize(provider_user:)
      @provider_user = provider_user
    end
  end
end
