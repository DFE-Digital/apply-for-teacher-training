class ProviderInterface::HeaderComponent < ViewComponent::Base
  attr_reader :navigation_items, :service_url, :product_name, :classes
  include ViewHelper

  def initialize(navigation_items:, product_name:, service_url:, classes: '')
    @navigation_items = navigation_items
    @product_name     = product_name
    @service_url      = service_url
    @classes          = classes
  end
end
