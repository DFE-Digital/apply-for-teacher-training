module SupportInterface
  class ApiTokensController < SupportInterfaceController
    def index
      @api_tokens = VendorApiToken.order(created_at: :desc)
    end

    def create
      provider = Provider.find(params[:vendor_api_token][:provider_id])
      @unhashed_token = VendorApiToken.create_with_random_token!(provider: provider)
    end
  end
end
