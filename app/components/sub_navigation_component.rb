class SubNavigationComponent < ActionView::Component::Base
  attr_reader :items

  def initialize(items:)
    @items = items
  end
end
