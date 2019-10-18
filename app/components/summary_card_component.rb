class SummaryCardComponent < ActionView::Component::Base
  validates :rows, presence: true

  def initialize(rows:)
    @rows = rows
  end

private

  attr_reader :rows
end
