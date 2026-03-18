module ProviderInterface
  class CurrentFiltersComponent < ApplicationComponent
    include ViewHelper

    attr_reader :applied_filters, :params_for_current_state

    def initialize(available_filters:, applied_filters:, params_for_current_state:)
      @params_for_current_state = params_for_current_state
      @applied_filters = applied_filters
      @available_filters = available_filters
    end

    def build_tag_url_query_params(heading:, tag_value:)
      tag_applied_filters = @applied_filters.clone
      tag_applied_filters[heading] = @applied_filters[heading].except(tag_value)
      tag_applied_filters
    end

    def retrieve_tag_text(heading, lookup_val)
      if heading.eql?('search')
        @applied_filters[:search][:candidates_name]
      else
        @available_filters.each do |available_filter|
          next unless available_filter.key(heading)

          available_filter[:input_config].each do |input_config|
            return input_config[:text].to_s if input_config.key(lookup_val)
          end
        end
      end
    end
  end
end
