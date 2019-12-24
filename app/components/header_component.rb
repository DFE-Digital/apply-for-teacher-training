class HeaderComponent < ActionView::Component::Base
  attr_reader :navigation_items

  def initialize(navigation_items:)
    @navigation_items = navigation_items
  end
end
