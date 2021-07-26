module ProviderInterface
  class SetupCompleteNextStepsComponent < ViewComponent::Base
    attr_reader :provider_user

    def initialize(provider_user:)
      @provider_user = provider_user
    end

    def user_can_manage_users?
      provider_user.authorisation.can_manage_users_for_at_least_one_provider?
    end
  end
end
