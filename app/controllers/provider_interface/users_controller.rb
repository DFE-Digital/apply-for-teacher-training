module ProviderInterface
  class UsersController < ProviderInterfaceController
    def index
      @provider = current_provider_user.providers.find(params[:organisation_id])
    end
  end
end
