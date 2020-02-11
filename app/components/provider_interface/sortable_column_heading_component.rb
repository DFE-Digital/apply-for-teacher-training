module ProviderInterface
  class SortableColumnHeadingComponent < ActionView::Component::Base
    include ViewHelper

    def initialize(sort_order:)
      @sort_order = sort_order
    end

    def toggle_sort_order
      @sort_order.to_sym == :desc ? :asc : :desc
    end

    def aria_sort_order
      @sort_order.to_sym == :desc ? 'descending' : 'ascending'
    end

    def column_name_with_arrow
      "Last updated"
    end
  end
end
