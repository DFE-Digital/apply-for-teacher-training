class SummaryCardHeaderComponent < ViewComponent::Base
  def initialize(title:, heading_level: 2, anchor: nil)
    @title = title
    @heading_level = heading_level
    @anchor = anchor
  end
end
