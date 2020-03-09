module ProviderInterface
  class ToggleFilterComponent < ActionView::Component::Base
    include ViewHelper

    attr_reader :sort_order, :current_sort_by, :filter_visible, :filter_options, :filter_selections

    def initialize(sort_order:, current_sort_by:, filter_visible:, filter_selections:)
      @sort_order = sort_order
      @current_sort_by = current_sort_by
      @filter_visible = filter_visible
      @filter_selections = filter_selections
    end

    def toggle_filter
      @filter_visible.eql?('true') ? 'false' : 'true'
    end

    def toggle_button_text
      @filter_visible.eql?('true') ? 'Hide filter' : 'Show filter'
    end
  end
end
