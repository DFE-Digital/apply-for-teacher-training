module SupportInterface
  class VendorAPIRequestDetailsComponent < ViewComponent::Base
    attr_reader :vendor_api_request

    def initialize(vendor_api_request)
      @vendor_api_request = vendor_api_request
    end

    delegate :status_code, :request_method, :request_path, :provider, to: :vendor_api_request

    def rows
      [
        { key: 'Status', value: status_code },
        { key: 'Method', value: request_method },
        { key: 'Path', value: request_path },
        { key: 'Provider', value: provider_name },
      ]
    end

  private

    def provider_name
      provider.present? ? vendor_api_request.provider.name : 'Unknown'
    end
  end
end
