module SupportInterface
  class DuplicateMatchesFilter
    include FilterParamsHelper

    attr_reader :applied_filters

    def initialize(params:)
      @applied_filters = compact_params(params)
    end

    def filters
      [
        {
          type: :search,
          heading: 'Email',
          value: applied_filters[:query],
          name: 'query',
        },
      ]
    end
  end
end
