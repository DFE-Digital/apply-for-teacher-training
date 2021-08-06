class TabNavigationComponent < ViewComponent::Base
  include ViewHelper
  attr_reader :items

  def initialize(items:)
    @items = items
  end

  def strip_query(url)
    url = Addressable::URI.parse(url)
    url.query_values = nil
    url.to_s
  end
end
