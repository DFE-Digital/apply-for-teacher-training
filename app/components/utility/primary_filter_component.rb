class PrimaryFilterComponent < ViewComponent::Base
  include ViewHelper

  attr_reader :filters, :primary_filter, :secondary_filters

  def initialize(filters:, primary_filter: nil, secondary_filters: [])
    @filters = filters
    @primary_filter = primary_filter
    @secondary_filters = secondary_filters
  end

  def render?
    primary_filter.present?
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

  def remove_search_tag_link(name)
    params = filters_to_params(filters)
    params.delete(name)
    params[:remove] = true # for removing last filter
    to_query(params)
  end

private

  def to_query(params)
    "?#{params.to_query}"
  end
end
