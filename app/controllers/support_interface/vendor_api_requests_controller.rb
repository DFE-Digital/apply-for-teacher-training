module SupportInterface
  class VendorAPIRequestsController < SupportInterfaceController
    def index
      @filter = SupportInterface::VendorAPIRequestsFilter.new(params: params)
      @vendor_api_requests = VendorAPIRequest.order(created_at: :desc).page(params[:page] || 1).per(15)

      if params[:q]
        @vendor_api_requests = @vendor_api_requests.where("CONCAT(request_path, ' ', request_body, ' ', response_body, ' ', hashed_token) ILIKE ?", "%#{params[:q]}%")
      end

      if params[:status_code]
        @vendor_api_requests = @vendor_api_requests.where('status_code IN (?)', params[:status_code])
      end

      %w[created_at request_path].each do |column|
        next unless params[column]

        @vendor_api_requests = @vendor_api_requests.where(column => params[column])
      end
    end
  end
end
