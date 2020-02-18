class BreakPlaceholderInWorkHistoryComponent < ActionView::Component::Base
  include ViewHelper

  attr_reader :work_break

  def initialize(work_break:)
    @work_break = work_break
  end

  def between_formatted_dates
    "between #{@work_break.start_date.to_s(:month_and_year)} and #{@work_break.end_date.to_s(:month_and_year)}"
  end

  def break_length
    if @work_break.length <= 12
      pluralize(@work_break.length, 'month')
    else
      years = @work_break.length / 12
      months = @work_break.length % 12

      "#{pluralize(years, 'year')} and #{pluralize(months, 'month')}"
    end
  end
end
