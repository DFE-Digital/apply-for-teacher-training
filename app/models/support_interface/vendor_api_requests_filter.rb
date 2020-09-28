module SupportInterface
  class VendorAPIRequestsFilter
    attr_reader :applied_filters

    def initialize(params:)
      @applied_filters = params
    end

    def filters
      @filters ||= [free_text] + [status_code]
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
      options = VendorAPIRequest.distinct(:status_code).pluck(:status_code).map do |status_code|
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
  end
end
