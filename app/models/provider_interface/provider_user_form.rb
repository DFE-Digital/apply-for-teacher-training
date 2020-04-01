module ProviderInterface
  class ProviderUserForm < SupportInterface::ProviderUserForm
    attr_accessor :current_provider_user

    def available_providers
      @available_providers ||= Provider.joins(provider_users_providers: :provider_user)
        .where('provider_users_providers.provider_user': current_provider_user)
        .where('provider_users_providers.manage_users': true)
        .order(name: :asc)
    end
  end
end
