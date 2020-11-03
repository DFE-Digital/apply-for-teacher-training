class SummaryCardHeaderComponent < ViewComponent::Base
  def initialize(title:, heading_level: 2)
    @title = title
    @heading_level = heading_level
  end
end
