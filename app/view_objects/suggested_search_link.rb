class SuggestedSearchLink
  include ActionView::Helpers::TextHelper
  attr_reader :radius, :count, :parameters, :including_non_salaried, :explicit_salary_filter

  def initialize(radius:, count:, parameters:, including_non_salaried: false, explicit_salary_filter: false)
    @radius = radius
    @count = count
    @parameters = parameters
    @including_non_salaried = including_non_salaried
    @explicit_salary_filter = explicit_salary_filter
  end

  def text
    count_prefix = "#{pluralize(count, 'course')} "
    count_prefix << (all_england? ? "across England" : "within #{radius} miles")
    count_prefix << (text_course_text.presence || "")
  end

  def url
    UnescapedQueryStringService.call(
      base_path: Rails.application.routes.url_helpers.results_path,
      parameters: suggested_search_link_parameters(radius: radius),
    )
  end

  def suffix
    return " - including both salaried courses and ones without a salary" if including_non_salaried

    ""
  end

private

  def all_england?
    radius.nil?
  end

  def suggested_search_link_parameters(radius:)
    return parameters.merge("rad" => radius) if radius.present?

    parameters
      .reject { |k, _v| %w[lat lng rad loc lq].include?(k) }
      .merge("l" => 2)
  end

  def text_course_text
    return " with a salary" if explicit_salary_filter

    ""
  end
end
