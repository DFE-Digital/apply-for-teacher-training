module ProviderInterface
  class PrimaryNavigation < ViewComponent::Base
    def initialize(navigation_items:)
      @navigation_items = navigation_items
    end
  end
end
