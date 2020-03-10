module ProviderInterface
  class FilterComponent < ActionView::Component::Base
    include ViewHelper

    attr_reader :additional_params, :available_filters, :applied_filters, :path

    def initialize(path:, available_filters:, applied_filters:, additional_params:)
      @path = path
      @available_filters = available_filters
      @applied_filters = applied_filters
      @additional_params = additional_params
    end

    def checkbox_checked?(heading:, name:)
      applied_filters.dig(heading, name) ? true : false
    end

    def filtering_page_path(*args)
      send(@path, *args)
    end
  end
end
