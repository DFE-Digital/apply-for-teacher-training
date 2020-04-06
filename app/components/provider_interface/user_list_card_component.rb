module ProviderInterface
  class UserListCardComponent < ActionView::Component::Base
    include ViewHelper

    attr_accessor :full_name, :email_address, :providers_text


    def initialize(provider_user:)
      @full_name = provider_user.full_name
      @email_address = provider_user.email_address
      @providers_text = calculate_providers_text(provider_user.providers)
    end

    def calculate_providers_text(providers)
      return providers.first if providers.size == 1
      return "#{providers.first.name} and #{TextCardinalizer.call(providers.size - 1)} more"
    end
  end
end
