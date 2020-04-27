class HeaderComponent < ViewComponent::Base
  attr_reader :navigation_items, :service_url, :service_name, :classes, :wide

  def initialize(navigation_items:, service_name:, service_url:, classes: '', wide: false)
    @navigation_items = navigation_items
    @service_name     = service_name
    @service_url      = service_url
    @classes          = classes
    @wide             = wide
  end
end
