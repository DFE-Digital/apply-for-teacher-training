module ProviderInterface
  class ProviderUserForm < SupportInterface::ProviderUserForm
    attr_accessor :current_provider_user

    def available_providers
      @available_providers ||= Provider
        .with_users_manageable_by(current_provider_user)
        .order(name: :asc)
    end
  end
end
