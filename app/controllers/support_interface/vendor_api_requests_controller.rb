module SupportInterface
  class VendorAPIRequestsController < SupportInterfaceController
    def index
      @vendor_api_requests = VendorAPIRequest.all.order(created_at: :desc)
    end
  end
end
