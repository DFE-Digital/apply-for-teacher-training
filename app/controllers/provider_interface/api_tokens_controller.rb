module ProviderInterface
  class ApiTokensController < ProviderInterfaceController
    def index
      @api_tokens = VendorApiToken.where(provider: current_provider_user.providers)
    end

    def create
      provider = current_provider_user.providers.find(params[:vendor_api_token][:provider_id])
      @unhashed_token = VendorApiToken.create_with_random_token!(provider: provider)
    end
  end
end
