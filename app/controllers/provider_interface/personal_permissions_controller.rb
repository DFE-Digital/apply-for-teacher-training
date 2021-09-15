module ProviderInterface
  class PersonalPermissionsController < ProviderInterfaceController
    def show
      @providers = current_provider_user.providers.order(:name)
    end
  end
end
