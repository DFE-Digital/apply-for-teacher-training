module SupportInterface
  class AnchorLinkComponent < ViewComponent::Base
    attr_reader :link_to_id

    def initialize(link_to_id:)
      @link_to_id = link_to_id
    end
  end
end
