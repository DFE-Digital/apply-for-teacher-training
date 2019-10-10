module SupportInterface
  class ApiTokensController < SupportInterfaceController
    def index
      @api_tokens = VendorApiToken.order(created_at: :desc)
    end

    def create
      @unhashed_token = VendorApiToken.create_with_random_token!
    end
  end
end
