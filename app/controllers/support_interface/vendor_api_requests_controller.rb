module SupportInterface
  class VendorAPIRequestsController < SupportInterfaceController
    PAGY_PER_PAGE = 30

    def index
      @filter = SupportInterface::VendorAPIRequestsFilter.new(params:)
      vendor_api_requests = if @filter.filtered?
                              VendorAPIRequestQuery.call(params: @filter.applied_filters)
                            else
                              VendorAPIRequest.none
                            end


      @pagy, @vendor_api_requests = pagy(vendor_api_requests, limit: PAGY_PER_PAGE)
    end
  end
end
