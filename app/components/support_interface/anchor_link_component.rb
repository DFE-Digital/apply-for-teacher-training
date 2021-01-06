module SupportInterface
  class AnchorLinkComponent < ViewComponent::Base
    attr_reader :link_to_id, :content

    def initialize(link_to_id:, content:)
      @link_to_id = link_to_id
      @content = content
    end
  end
end
