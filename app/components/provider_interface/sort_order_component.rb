module ProviderInterface
  class SortOrderComponent < ViewComponent::Base
    attr_reader :page_state

    def initialize(page_state:)
      @page_state = page_state
    end
  end
end
