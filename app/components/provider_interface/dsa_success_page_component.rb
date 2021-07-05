module ProviderInterface
  class DsaSuccessPageComponent < ViewComponent::Base
    attr_reader :provider_user, :provider_permission_setup_pending

    def initialize(provider_user:, provider_permission_setup_pending:)
      @provider_user = provider_user
      @provider_permission_setup_pending = provider_permission_setup_pending
    end

    def user_can_manage_users?
      provider_user.authorisation.can_manage_users_for_at_least_one_provider?
    end
  end
end
