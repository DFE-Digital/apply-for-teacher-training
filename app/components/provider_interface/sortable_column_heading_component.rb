module ProviderInterface
  class SortableColumnHeadingComponent < ActionView::Component::Base
    include ViewHelper

    attr_reader :column_name, :current_sort_by, :css_class, :filter_options, :filter_visible

    def initialize(column_name:, css_class:, page_state:)
      @column_name = column_name
      @css_class = css_class
      @current_sort_by = page_state.sort_by
      @sort_order = page_state.sort_order
      @filter_options = page_state.filter_options
      @filter_visible = page_state.filter_visible
    end

    def default_sort_order
      'desc'
    end

    def toggle_sort_order
      @sort_order.to_sym == :desc ? :asc : :desc
    end

    def aria_sort_order
      @sort_order.to_sym == :desc ? 'descending' : 'ascending'
    end

    def sort_by
      column_name.parameterize
    end

    def should_have_sort?
      sort_by.eql?(current_sort_by)
    end
  end
end
