module ProviderInterface
  class OrganisationSettingsController < ProviderInterfaceController
    def show
      @providers = current_user.providers.order(:name)
    end
  end
end
