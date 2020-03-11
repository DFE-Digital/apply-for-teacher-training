module ProviderInterface
  class FilterComponent < ActionView::Component::Base
    include ViewHelper

    attr_reader :params_for_current_state, :available_filters, :applied_filters, :path

    def initialize(path:, available_filters:, applied_filters:, params_for_current_state:)
      @path = path
      @available_filters = available_filters
      @applied_filters = applied_filters
      @params_for_current_state = params_for_current_state
    end

    def checkbox_checked?(heading:, name:)
      applied_filters.dig(heading, name) ? true : false
    end

    def filtering_page_path(*args)
      send(@path, *args)
    end
  end
end
