module SupportInterface
  class VendorAPIRequestsController < SupportInterfaceController
    def index
      @filter = SupportInterface::VendorAPIRequestsFilter.new(params:)
      vendor_api_requests = @filter.filter_records(VendorAPIRequest.includes(:provider).order(created_at: :desc))

      @pagy, @vendor_api_requests = pagy(vendor_api_requests, items: 30)
    end
  end
end
