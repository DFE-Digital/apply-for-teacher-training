module SupportInterface
  class VendorAPIRequestsFilter
    attr_reader :applied_filters

    def initialize(params:)
      @applied_filters = params
    end

    def filters
      @filters ||= [free_text] + [request_method] + [status_code] + [provider]
    end

    def filter_records(vendor_api_requests)
      if applied_filters[:q]
        vendor_api_requests = vendor_api_requests.where("CONCAT(request_path, ' ', request_body, ' ', response_body) ILIKE ?", "%#{applied_filters[:q]}%")
      end

      if applied_filters[:status_code]
        vendor_api_requests = vendor_api_requests.where(status_code: applied_filters[:status_code])
      end

      if applied_filters[:request_method]
        vendor_api_requests = vendor_api_requests.where(request_method: applied_filters[:request_method])
      end

      if applied_filters[:provider_id]
        vendor_api_requests = vendor_api_requests.where(provider_id: applied_filters[:provider_id])
      end

      %w[created_at request_path].each do |column|
        next unless applied_filters[column]

        vendor_api_requests = vendor_api_requests.where(column => applied_filters[column])
      end

      vendor_api_requests
    end

  private

    def free_text
      {
        type: :search,
        heading: 'Search',
        value: applied_filters[:q],
        name: 'q',
      }
    end

    def status_code
      options = VendorAPIRequest.distinct(:status_code).pluck(:status_code).map(&:to_s).map do |status_code|
        {
          value: status_code,
          label: status_code,
          checked: applied_filters[:status_code]&.include?(status_code),
        }
      end

      {
        type: :checkboxes,
        heading: 'Status code',
        name: 'status_code',
        options: options,
      }
    end

    def request_method
      options = VendorAPIRequest.distinct(:request_method).pluck(:request_method).compact.map do |request_method|
        {
          value: request_method,
          label: request_method,
          checked: applied_filters[:request_method]&.include?(request_method),
        }
      end

      {
        type: :checkboxes,
        heading: 'Method',
        name: 'request_method',
        options: options,
      }
    end

    def provider
      options = Provider.where(id: VendorAPIRequest.distinct(:provider_id).select(:provider_id)).map do |provider|
        {
          value: provider.id.to_s,
          label: provider.name,
          checked: applied_filters[:provider_id]&.include?(provider.id.to_s),
        }
      end

      {
        type: :checkboxes,
        heading: 'Provider',
        name: 'provider_id',
        options: options,
      }
    end
  end
end
