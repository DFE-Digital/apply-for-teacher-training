module ProviderInterface
  class ToggleFilterComponent < ActionView::Component::Base
    include ViewHelper

    attr_reader :sort_order, :current_sort_by, :filter_visible, :toggle_button_text

    def initialize(sort_order:, current_sort_by:, filter_visible:)
      @sort_order = sort_order
      @current_sort_by = current_sort_by
      @filter_visible = filter_visible
    end

    def toggle_filter
      @filter_visible.eql?('true') ? 'false' : 'true'
    end

    def toggle_button_text
      @filter_visible.eql?('true') ? 'Hide filter' : 'Show filter'
    end
  end
end
