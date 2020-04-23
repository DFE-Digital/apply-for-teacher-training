module ProviderInterface
  class UserListCardComponent < ViewComponent::Base
    include ViewHelper

    attr_reader :provider_user, :full_name, :email_address

    def initialize(provider_user:)
      @provider_user = provider_user
      @full_name = provider_user.full_name
      @email_address = provider_user.email_address
    end

    def providers_text
      providers = provider_user.providers
      return providers.first.name if providers.size == 1

      "#{providers.first.name} and #{TextCardinalizer.call(providers.size - 1)} more"
    end
  end
end
