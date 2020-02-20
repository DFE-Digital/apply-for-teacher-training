module ProviderInterface
  class FilterComponent < ActionView::Component::Base
    include ViewHelper

    attr_reader :sort_order, :current_sort_by, :filter_options

    def initialize(sort_order:, current_sort_by:, filter_options:)
      @sort_order = sort_order
      @current_sort_by = current_sort_by
      @filter_options = filter_options
    end
  end
end
