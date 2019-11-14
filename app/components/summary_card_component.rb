class SummaryCardComponent < ActionView::Component::Base
  validates :rows, presence: true

  def initialize(rows:, border: true)
    @rows = rows
    @border = border
  end

  def border_css_class
    @border ? '' : 'no-border'
  end

private

  attr_reader :rows
end
