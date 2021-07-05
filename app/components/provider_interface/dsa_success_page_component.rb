module ProviderInterface
  class DsaSuccessPageComponent < ViewComponent::Base
    attr_reader :provider_user, :provider_permission_setup_pending

    def initialize(provider_user:, provider_permission_setup_pending:)
      @provider_user = provider_user
      @provider_permission_setup_pending = provider_permission_setup_pending
    end
  end
end
