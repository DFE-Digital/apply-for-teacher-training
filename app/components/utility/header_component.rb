class HeaderComponent < ViewComponent::Base
  attr_reader :classes, :product_name, :service_name, :service_link, :phase_tag, :navigation_items, :navigation_classes

  def initialize(service_link: nil, classes: '', product_name: nil, homepage_url: nil, service_name: nil, phase_tag: false, navigation_items: [], navigation_classes: '')
    @classes            = classes
    @product_name       = product_name
    @homepage_url       = homepage_url
    @service_name       = service_name
    @service_link       = service_link
    @phase_tag          = phase_tag
    @navigation_items   = navigation_items
    @navigation_classes = navigation_classes
  end

private

  def govuk_url
    t('govuk.url')
  end

  def homepage_url
    @homepage_url || govuk_url
  end
end
