class BreakInWorkHistoryComponent < ActionView::Component::Base
  include ViewHelper

  attr_reader :work_break

  def initialize(work_break:)
    @work_break = work_break
  end

  def work_break_rows
    [reason_row, dates_row]
  end

private

  def reason_row
    {
      key: 'Description',
      value: @work_break.reason,
    }
  end

  def dates_row
    {
      key: 'Dates',
      value: "#{formatted_start_date} - #{formatted_end_date}",
    }
  end

  def formatted_start_date
    @work_break.start_date.to_s(:month_and_year)
  end

  def formatted_end_date
    @work_break.end_date.to_s(:month_and_year)
  end
end
