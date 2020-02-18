module ProviderInterface
  class FilterComponent < ActionView::Component::Base
    include ViewHelper

    attr_reader :sort_order, :current_sort_by

    def initialize(sort_order:, current_sort_by:)
      @sort_order = sort_order
      @current_sort_by = current_sort_by
    end
  end
end
