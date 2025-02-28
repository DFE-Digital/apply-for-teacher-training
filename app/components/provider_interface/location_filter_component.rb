class ProviderInterface::LocationFilterComponent < ViewComponent::Base
  attr_reader :filter

  def initialize(filter:)
    @filter = filter
  end

  def select_options
    options = []
    filter[:radius_values].map do |radius|
      options << content_tag(
        :option,
        pluralize(radius, 'mile'),
        value: radius,
        selected: radius == 10,
      )
    end
    options.join.html_safe
  end
end
