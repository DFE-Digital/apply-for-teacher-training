module SupportInterface
  class VendorAPIRequestsController < SupportInterfaceController
    PAGY_PER_PAGE = 30

    def index
      @filter = SupportInterface::VendorAPIRequestsFilter.new(params:)
      vendor_api_requests = @filter.filter_records(VendorAPIRequest.includes(:provider).order(created_at: :desc))

      @pagy, @vendor_api_requests = pagy(vendor_api_requests, limit: PAGY_PER_PAGE)
    end
  end
end
