module ProviderInterface
  class ToggleFilterComponent < ActionView::Component::Base
    include ViewHelper

    attr_reader :sort_order, :current_sort_by, :filter_visible, :filter_options

    def initialize(page_state:)
      @sort_order = page_state.sort_order
      @current_sort_by = page_state.sort_by
      @filter_visible = page_state.filter_visible
      @filter_options = page_state.filter_options
    end

    def toggle_filter
      @filter_visible.eql?('true') ? 'false' : 'true'
    end

    def toggle_button_text
      @filter_visible.eql?('true') ? 'Hide filter' : 'Show filter'
    end
  end
end
