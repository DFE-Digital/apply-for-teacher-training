module SupportInterface
  class VendorAPIRequestsController < SupportInterfaceController
    def index
      @filter = SupportInterface::VendorAPIRequestsFilter.new(params: params)
      @vendor_api_requests = @filter.filter_records(
        VendorAPIRequest.includes(:provider).order(created_at: :desc).page(params[:page] || 1).per(30),
      )
    end
  end
end
