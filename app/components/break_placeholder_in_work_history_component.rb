class BreakPlaceholderInWorkHistoryComponent < ActionView::Component::Base
  include ViewHelper

  attr_reader :work_break

  def initialize(work_break:)
    @work_break = work_break
  end

  def between_formatted_dates
    "between #{@work_break.start_date.to_s(:month_and_year)} and #{@work_break.end_date.to_s(:month_and_year)}"
  end
end
