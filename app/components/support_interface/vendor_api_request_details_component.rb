module SupportInterface
  class VendorAPIRequestDetailsComponent < SummaryListComponent
    include ViewHelper
    attr_reader :vendor_api_request

    def initialize(vendor_api_request)
      @vendor_api_request = vendor_api_request
    end

    delegate :status_code, :request_method, :request_path, :provider, to: :vendor_api_request

    def rows
      rows = [
        { key: 'Status', value: status_code },
        { key: 'Method', value: request_method },
        { key: 'Path', value: request_path },
        { key: 'Provider', value: provider_name },
      ]

      if application_choice_id.present?
        rows << {
          key: 'Application details',
          value: govuk_link_to('View in support', Rails.application.routes.url_helpers.support_interface_application_choice_path(application_choice_id)),
        }
      end

      rows
    end

  private

    def provider_name
      provider.present? ? vendor_api_request.provider.name : 'Unknown'
    end

    def application_choice_id
      request_path.match(/applications\/(\d+)/).to_a.last
    end
  end
end
