module ProviderInterface
  class FilterComponent < ViewComponent::Base
    include ViewHelper

    attr_reader :params_for_current_state, :available_filters, :applied_filters

    def initialize(available_filters:, applied_filters:, params_for_current_state:)
      @available_filters = available_filters
      @applied_filters = applied_filters
      @params_for_current_state = params_for_current_state
    end

    def checkbox_checked?(heading:, name:)
      applied_filters.dig(heading, name) ? true : false
    end

    def is_candidates_name_search_field?(filter_group)
      filter_group[:heading].parameterize.eql?('candidate-s-name')
    end

    def form_group_fields_greater_than_one?(filter_group)
      filter_group[:input_config].size > 1
    end
  end
end
