module SupportInterface
  class VendorAPIRequestsController < SupportInterfaceController
    def index
      @filter = SupportInterface::VendorAPIRequestsFilter.new(params: params)
      @vendor_api_requests = VendorAPIRequest.includes(:provider).order(created_at: :desc).page(params[:page] || 1).per(15)

      if params[:q]
        @vendor_api_requests = @vendor_api_requests.where("CONCAT(request_path, ' ', request_body, ' ', response_body) ILIKE ?", "%#{params[:q]}%")
      end

      if params[:status_code]
        @vendor_api_requests = @vendor_api_requests.where('status_code IN (?)', params[:status_code])
      end

      if params[:provider_id]
        @vendor_api_requests = @vendor_api_requests.where('provider_id IN (?)', params[:provider_id])
      end

      %w[created_at request_path].each do |column|
        next unless params[column]

        @vendor_api_requests = @vendor_api_requests.where(column => params[column])
      end
    end
  end
end
