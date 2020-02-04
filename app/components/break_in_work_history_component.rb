class BreakInWorkHistoryComponent < ActionView::Component::Base
  attr_reader :break_in_months

  def initialize(work_break:)
    @break_in_months = work_break.break_in_months
  end
end
