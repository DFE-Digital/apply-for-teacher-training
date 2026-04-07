module SupportInterface
  class VendorAPIRequestsFilter
    include FilterParamsHelper

    attr_reader :applied_filters

    STATUS_CODES = [200, 302, 401, 403, 404, 422, 429].freeze
    REQUEST_METHODS = %w[GET POST HEAD OPTIONS].freeze

    def initialize(params:)
      @applied_filters = compact_params(params)
    end

    def filters
      @filters ||= [provider_code] + [free_text] + [request_method] + [status_code]
    end

    def filtered?
      applied_filters[:provider_code].present?
    end

    def valid_provider?
      Provider.find_by(code: applied_filters[:provider_code].upcase).present?
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
      options = STATUS_CODES.map do |status_code|
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
        options:,
      }
    end

    def request_method
      options = REQUEST_METHODS.map do |request_method|
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
        options:,
      }
    end

    def provider_code
      {
        type: :search,
        heading: 'Provider code',
        name: 'provider_code',
        value: applied_filters[:provider_code],
      }
    end
  end
end
