module SupportInterface
  class AnchorLinkComponent < ViewComponent::Base
    include ViewHelper
    attr_reader :link_to_id

    def initialize(link_to_id:)
      @link_to_id = link_to_id
    end
  end
end
