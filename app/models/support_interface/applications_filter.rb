module SupportInterface
  class ApplicationsFilter
    attr_reader :applied_filters

    def initialize(params:)
      @applied_filters = params
    end

    def filters
      [
        {
          type: :search,
          heading: 'Name or email',
          value: applied_filters[:q],
          name: 'q',
        },
        {
          type: :checkboxes,
          heading: 'Phase',
          name: 'phase',
          options: [
            {
              value: "apply_1",
              label: "Apply 1",
              checked: applied_filters[:phase]&.include?("apply_1"),
            },
            {
              value: "apply_2",
              label: "Apply 2",
              checked: applied_filters[:phase]&.include?("apply_2"),
            },
          ],
        }
      ]
    end
  end
end
