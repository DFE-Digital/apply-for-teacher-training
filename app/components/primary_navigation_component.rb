class PrimaryNavigationComponent < ViewComponent::Base
  def initialize(navigation_items:)
    @navigation_items = navigation_items
  end
end
