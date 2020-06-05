module ProviderInterface
  class FilterComponent < ViewComponent::Base
    include ViewHelper

    attr_reader :page_state
    delegate :filters, to: :page_state

    def initialize(page_state:)
      @page_state = page_state
    end

    def tags_for_active_filter(filter)
      case filter[:type]
      when :search
        [{ title: filter[:value], remove_link: remove_search_tag_link(filter[:name]) }]
      when :checkboxes
        filter[:options].each_with_object([]) do |option, arr|
          if option[:checked]
            arr << { title: option[:label], remove_link: remove_checkbox_tag_link(filter[:name], option[:value]) }
          end
        end
      end
    end

    def toggle_filter_off_params
      toggle = { filter_visible: [@page_state.filter_visible?] }
      @page_state.applied_filters.merge(toggle)
    end

    def remove_checkbox_tag_link(name, value)
      params = filters_to_params(filters)
      params[name].reject! { |val| val == value }
      '?' + params.to_query
    end

    def remove_search_tag_link(name)
      params = filters_to_params(filters)
      params.delete(name)
      '?' + params.to_query
    end

    def active_filters
      filters.select { |f| filter_active?(f) }
    end

    def filter_active?(filter)
      case filter[:type]
      when :search
        filter[:value].present?
      when :checkboxes
        filter[:options].any? { |o| o[:checked] }
      end
    end

    def filters_to_params(filters)
      filters.each_with_object({}) do |filter, hash|
        case filter[:type]
        when :search
          hash[filter[:name]] = filter[:value]
        when :checkboxes
          hash[filter[:name]] = filter[:options].select { |o| o[:checked] }.map { |o| o[:value] }
        end
      end
    end
  end
end
