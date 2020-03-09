module ProviderInterface
  class CurrentFiltersComponent < ActionView::Component::Base
    include ViewHelper

    attr_reader :applied_filters, :additional_params, :path

    def initialize(path:, available_filters:, applied_filters:, additional_params:)
      @additional_params = additional_params
      @applied_filters = applied_filters
      @available_filters = available_filters
      @path = path
    end

    def build_tag_url_query_params(heading:, tag_value:)
      tag_applied_filters = @applied_filters.clone
      tag_applied_filters[heading] = @applied_filters[heading].except(tag_value)
      tag_applied_filters
    end

    def retrieve_tag_text(heading, lookup_val)
      @available_filters.each do |available_filter|
        if available_filter.key(heading)
          available_filter[:checkbox_config].each do |checkbox_config|
            return checkbox_config[:text].to_s if checkbox_config.key(lookup_val)
          end
        end
      end
    end

    def filtering_page_path(*args)
      send(@path, *args)
    end
  end
end
