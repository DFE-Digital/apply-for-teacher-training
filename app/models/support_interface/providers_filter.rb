module SupportInterface
  class ProvidersFilter
    attr_reader :applied_filters

    def initialize(params:)
      @applied_filters = params
    end

    def filters
      [
        {
          type: :search,
          heading: 'Name or code',
          value: applied_filters[:q],
          name: 'q',
        },
      ]
    end
  end
end
