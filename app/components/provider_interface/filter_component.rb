module ProviderInterface
  class FilterComponent < ActionView::Component::Base
    include ViewHelper

    attr_reader :sort_order, :current_sort_by, :filter_options

    def initialize(page_state:)
      @sort_order = page_state.sort_order
      @current_sort_by = page_state.sort_by
      @filter_options = page_state.filter_options
    end
  end
end
