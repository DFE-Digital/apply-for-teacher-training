class HeaderComponent < ViewComponent::Base
  attr_reader :classes, :product_name, :service_name, :service_link, :phase_tag, :navigation_items, :navigation_classes

  def initialize(classes: '', product_name: nil, service_name: nil, service_link:, phase_tag: false, navigation_items: [], navigation_classes: '')
    @classes            = classes
    @product_name       = product_name
    @service_name       = service_name
    @service_link       = service_link
    @phase_tag          = phase_tag
    @navigation_items   = navigation_items
    @navigation_classes = navigation_classes
  end
end
