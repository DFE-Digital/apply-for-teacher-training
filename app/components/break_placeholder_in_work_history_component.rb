class BreakPlaceholderInWorkHistoryComponent < ActionView::Component::Base
  include ViewHelper

  attr_reader :work_break

  def initialize(work_break:)
    @work_break = work_break
  end
end
