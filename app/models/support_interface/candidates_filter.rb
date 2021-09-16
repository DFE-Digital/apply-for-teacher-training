module SupportInterface
  class CandidatesFilter
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
          value: applied_filters[:q],
          name: 'q',
        },
        {
          type: :search,
          css_classes: 'govuk-input--width-5',
          heading: 'Candidate ID',
          value: applied_filters[:candidate_number],
          name: 'candidate_number',
        },
      ]
    end
  end
end
