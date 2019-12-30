class HeaderComponent < ActionView::Component::Base
  attr_reader :navigation_items, :service_url, :service_name, :classes

  def initialize(navigation_items:, service_name:, service_url:, classes: '')
    @navigation_items = navigation_items
    @service_name     = service_name
    @service_url      = service_url
    @classes          = classes
  end
end
