class HeaderComponent < ViewComponent::Base
  attr_reader :classes, :product_name, :service_name, :service_name_href, :phase_tag, :navigation_items

  def initialize(classes: '', product_name: nil, service_name: nil, service_name_href:, phase_tag: false, navigation_items:)
    @classes           = classes
    @product_name      = product_name
    @service_name      = service_name
    @service_name_href = service_name_href
    @phase_tag         = phase_tag
    @navigation_items  = navigation_items
  end
end
