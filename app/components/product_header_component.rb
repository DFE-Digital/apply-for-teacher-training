class ProductHeaderComponent < ViewComponent::Base
  attr_reader :navigation_items, :service_url, :product_name, :phase_tag, :classes
  include ViewHelper

  def initialize(navigation_items:, service_url:, product_name:, phase_tag: false, classes: '')
    @navigation_items = navigation_items
    @service_url      = service_url
    @product_name     = product_name
    @phase_tag        = phase_tag
    @classes          = classes
  end

  def phase_tag_class
    return '' if HostingEnvironment.production?

    "govuk-tag--#{HostingEnvironment.phase_colour}"
  end
end
