class FilterComponent < ViewComponent::Base
  include ViewHelper

  attr_reader :filter
  delegate :filters, to: :filter

  def initialize(filter:)
    @filter = filter
  end

  def tags_for_active_filter(filter)
    case filter[:type]
    when :location_search
      [
        {
          title: filter[:original_location],
          hint: filter[:hint],
          remove_link: location_filter_tag_link,
        },
      ]
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

  def location_filter_tag_link
    params = filters_to_params(filters)
    params.delete(:original_location)
    params[:remove] = true # for removing last filter
    to_query(params)
  end

  def remove_checkbox_tag_link(name, value)
    params = filters_to_params(filters)
    params[name].reject! { |val| val == value }
    params[:remove] = true # for removing last filter
    to_query(params)
  end

  def remove_search_tag_link(name)
    params = filters_to_params(filters)
    params.delete(name)
    params[:remove] = true # for removing last filter
    to_query(params)
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
    to_query(link_params)
  end

  def filter_active?(filter)
    case filter[:type]
    when :location_search
      active_location_filter?(filter)
    when :search
      filter[:primary] != true && filter[:value].present?
    when :checkboxes, :checkbox_filter
      filter[:options].any? { |o| o[:checked] }
    end
  end

  def filters_to_params(filters)
    filters.each_with_object({}) do |filter, hash|
      case filter[:type]
      when :location_search
        hash[:original_location] = filter[:original_location]
      when :search
        hash[filter[:name]] = filter[:value]
      when :checkboxes, :checkbox_filter
        hash[filter[:name]] = filter[:options].select { |o| o[:checked] }.map { |o| o[:value] }
      end
    end
  end

  def show_bottom_button?
    if @filter.respond_to?(:show_bottom_button?)
      @filter.show_bottom_button?
    else
      false
    end
  end

  def multiple_fields?(filter)
    field_count(filter) > 1 # to determine whether a fieldset is required
  end

private

  def to_query(params)
    "?#{params.to_query}"
  end

  def active_location_filter?(filter_hash)
    filter_hash[:original_location].present?
  end

  def field_count(filter)
    case filter[:type]
    when :checkboxes, :checkbox_filter # fieldsets should group related checkboxes but other types are single fields
      filter[:options].size
    else
      1
    end
  end
end
