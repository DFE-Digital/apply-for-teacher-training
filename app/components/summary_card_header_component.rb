class SummaryCardHeaderComponent < ActionView::Component::Base
  def initialize(title:, heading_level: 2, check_icon: false)
    @title = title
    @heading_level = heading_level
    @check_icon = check_icon
  end
end
