module ProviderInterface
  class FilterComponent < ActionView::Component::Base
    include ViewHelper

    def initialize(sting)
      @sting = sting
    end

  end
end
