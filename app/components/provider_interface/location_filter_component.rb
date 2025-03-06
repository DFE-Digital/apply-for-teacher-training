class ProviderInterface::LocationFilterComponent < ViewComponent::Base
  attr_reader :filter

  def initialize(filter:)
    @filter = filter
  end

  def select_options
    options = []
    selected_value = filter[:within].to_i.positive? ? filter[:within].to_i : 10

    filter[:radius_values].map do |radius|
      options << content_tag(
        :option,
        pluralize(radius, 'mile'),
        value: radius,
        selected: radius == selected_value,
      )
    end
    options.join.html_safe
  end
end
