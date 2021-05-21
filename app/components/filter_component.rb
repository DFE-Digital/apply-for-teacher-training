class FilterComponent < ViewComponent::Base
  include ViewHelper

  attr_reader :filter
  delegate :filters, to: :filter

  def initialize(filter:)
    @filter = filter
  end

  def tags_for_active_filter(filter)
    case filter[:type]
    when :search
      [{ title: filter[:value], remove_link: remove_search_tag_link(filter[:name]) }]
    when :checkboxes, :checkbox_filter
      filter[:options].each_with_object([]) do |option, arr|
        if option[:checked]
          arr << { title: option[:label], remove_link: remove_checkbox_tag_link(filter[:name], option[:value]) }
        end
      end
    end
  end

  def remove_checkbox_tag_link(name, value)
    params = filters_to_params(filters)
    params[name].reject! { |val| val == value }
    params[:remove] = true # for removing last filter
    '?' + params.to_query
  end

  def remove_search_tag_link(name)
    params = filters_to_params(filters)
    params.delete(name)
    params[:remove] = true # for removing last filter
    '?' + params.to_query
  end

  def active_filters
    filters.select { |f| filter_active?(f) }
  end

  def primary_filter
    @primary_filter ||= filters.find { |f| f[:primary] }
  end

  def secondary_filters
    @secondary_filters ||= filters - [primary_filter]
  end

  def clear_filters_link
    link_params = { remove: true }
    link_params.merge!(filters_to_params([primary_filter])) if primary_filter.present?
    '?' + link_params.to_query
  end

  def filter_active?(filter)
    case filter[:type]
    when :search
      filter[:primary] != true && filter[:value].present?
    when :checkboxes, :checkbox_filter
      filter[:options].any? { |o| o[:checked] }
    end
  end

  def filters_to_params(filters)
    filters.each_with_object({}) do |filter, hash|
      case filter[:type]
      when :search
        hash[filter[:name]] = filter[:value]
      when :checkboxes, :checkbox_filter
        hash[filter[:name]] = filter[:options].select { |o| o[:checked] }.map { |o| o[:value] }
      end
    end
  end
end
