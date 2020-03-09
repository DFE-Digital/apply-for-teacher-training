module ProviderInterface
  class FilterComponent < ActionView::Component::Base
    include ViewHelper

    attr_reader :additional_params, :available_filters, :applied_filters

    def initialize(path:, available_filters:, applied_filters:, additional_params:)
      @path = path
      @available_filters = available_filters
      @applied_filters = applied_filters
      @additional_params = additional_params
    end

    def checkbox_checked?(heading:, name:)
      applied_filters.dig(heading, name) ? true : false
    end

    def build_tag_url_query_params(heading:, tag_value:, applied_filters:)
      tag_applied_filters = applied_filters.clone
      tag_applied_filters[heading] = applied_filters[heading].except(tag_value)
      tag_applied_filters
    end

    def retrieve_tag_text(heading, lookup_val)
      available_filters.each do |available_filter|
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
