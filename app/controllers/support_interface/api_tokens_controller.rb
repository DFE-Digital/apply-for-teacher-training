module SupportInterface
  class APITokensController < SupportInterfaceController
    def index
      @api_tokens = VendorAPIToken.order(created_at: :desc)
    end

    def create
      provider = Provider.find(params[:vendor_api_token][:provider_id])
      @unhashed_token = VendorAPIToken.create_with_random_token!(provider: provider)
    end
  end
end
